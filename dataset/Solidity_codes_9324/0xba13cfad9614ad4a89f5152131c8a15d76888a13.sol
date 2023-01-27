


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
}



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
}



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
}



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
}



pragma solidity >=0.6.0 <0.8.0;

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
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



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}



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
}



pragma solidity >=0.6.0 <0.8.0;


pragma solidity ^0.6.0;

interface IStrategy {

    function want() external view returns (address);


    function deposit() external;


    function withdraw(address) external;


    function withdraw(uint256) external;


    function balanceOf() external view returns (uint256);


    function setController(address) external;


    function setWant(address) external;


    function getRewards() external;


    function claim(address) external returns (bool);

}


pragma solidity ^0.6.0;

interface IController {

    function withdraw(address, uint256) external;


    function earn(address, uint256) external;


    function rewards() external view returns (address);


    function vaults(address) external view returns (address);


    function strategies(address) external view returns (address);


    function approvedStrategies(address, address) external view returns (bool);


    function setVault(address, address) external;


    function setStrategy(address, address) external;


    function converters(address, address) external view returns (address);


    function claim(address, address) external;


    function getRewardStrategy(address _strategy) external;

}


pragma solidity ^0.6.0;










abstract contract BaseStrategy is IStrategy, Ownable, Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Withdrawn(
        address indexed _token,
        uint256 indexed _amount,
        address indexed _to
    );

    address internal _want;

    address public controller;

    modifier onlyController() {
        require(_msgSender() == controller, "!controller");
        _;
    }

    modifier onlyControllerOrVault() {
        require(
            _msgSender() == controller ||
                _msgSender() == IController(controller).vaults(_want),
            "!controller|vault"
        );
        _;
    }

    function _configure(
        address _wantAddress,
        address _controllerAddress,
        address _governance
    ) internal {
        _want = _wantAddress;
        controller = _controllerAddress;
        transferOwnership(_governance);
    }

    function setController(address _newController) external override onlyOwner {
        require(controller != _newController, "!old");
        controller = _newController;
    }

    function setWant(address _newWant) external override onlyOwner {
        require(_want != _newWant, "!old");
        _want = _newWant;
    }

    function want() external view override returns (address) {
        return _want;
    }

    function withdraw(address _token) external virtual override onlyController {
        require(address(_token) != address(_want), "!want");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(controller, balance);
        emit Withdrawn(_token, balance, controller);
    }

    function withdraw(uint256 _amount)
        public
        virtual
        override
        onlyControllerOrVault
    {
        uint256 _balance = IERC20(_want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        address _vault = IController(controller).vaults(_want);
        IERC20(_want).safeTransfer(_vault, _amount);
        emit Withdrawn(_want, _amount, _vault);
    }

    function balanceOf() public view virtual override returns (uint256) {
        return IERC20(_want).balanceOf(address(this));
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);
}


pragma solidity ^0.6.0;

interface IVaultStakingRewards {

    function getReward(bool _claimUnderlying) external;

    function notifyRewardAmount(address _rewardToken, uint256 _reward) external;

}


pragma solidity ^0.6.0;



abstract contract ClaimableStrategy is BaseStrategy {
    event ClaimedReward(address rewardToken, uint256 amount);

    function claim(address _rewardToken)
        external
        override
        onlyControllerOrVault
        returns (bool)
    {
        address _vault = IController(controller).vaults(_want);
        require(_vault != address(0), "!vault 0");
        IERC20 token = IERC20(_rewardToken);
        uint256 amount = token.balanceOf(address(this));
        if (amount > 0) {
            token.safeTransfer(_vault, amount);
            IVaultStakingRewards(_vault).notifyRewardAmount(
                _rewardToken,
                amount
            );
            emit ClaimedReward(_rewardToken, amount);
            return true;
        }
        return false;
    }
}


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IBooster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);


    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);


    function depositAll(uint256 _pid, bool _stake) external returns (bool);


    function poolInfo(uint256 _index) external view returns (PoolInfo memory);


    function poolLength() external view returns (uint256);

}


pragma solidity ^0.6.0;

interface IRewards {

    function stake(address, uint256) external;


    function stake(uint256) external;


    function stakeFor(address, uint256) external;


    function withdraw(address, uint256) external;


    function exit(address) external;


    function getReward(bool) external;


    function getReward(address) external;


    function getReward() external returns (bool);


    function queueNewRewards(uint256) external;


    function notifyRewardAmount(uint256) external;


    function addExtraReward(address) external;


    function stakingToken() external returns (address);


    function withdraw(uint256, bool) external returns(bool);


    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);


    function earned(address account) external view returns (uint256);


    function depositAll(bool, address) external;


    function deposit(uint256, bool) external;

}


pragma solidity ^0.6.0;

interface ICVXRewards {

    function withdraw(uint256 _amount, bool claim) external;

    function getReward(bool _stake) external;

    function stake(uint256 _amount) external;

}


pragma solidity ^0.6.0;

interface ICurveCvxCrvStableSwap {

  function add_liquidity(
      uint256[2] calldata _amounts,
      uint256 _min_mint_amount,
      address _receiver
  ) external returns(uint256);


  function calc_token_amount(
      uint256[2] calldata _amounts,
      bool _is_deposit
  ) external view returns(uint256);

}




pragma solidity ^0.6.0;

interface IVaultTransfers {

    function deposit(uint256 _amount) external;


    function depositFor(uint256 _amount, address _for) external;


    function depositAll() external;


    function withdraw(uint256 _amount) external;


    function withdrawAll() external;

}


pragma solidity ^0.6.0;








contract CvxCrvStrategy is ClaimableStrategy {


    uint256 public constant MAX_BPS = 10000;

    struct Settings {
        address crvRewards;
        address cvxRewards;
        address convexBooster;
        address crvDepositor;
        address crvToken;
        uint256 poolIndex;
        address cvxCrvToken;
        address curveCvxCrvStableSwapPool;
        uint256 curveCvxCrvIndexInStableSwapPool;
        uint256 curveAddLiquiditySlippageTolerance; // in bps, ex: 9500 == 5%
    }

    Settings public poolSettings;

    function configure(
        address _wantAddress,
        address _controllerAddress,
        address _governance,
        Settings memory _poolSettings
    ) public onlyOwner initializer {

        _configure(_wantAddress, _controllerAddress, _governance);
        poolSettings = _poolSettings;
    }

    function setPoolIndex(uint256 _newPoolIndex) external onlyOwner {

        poolSettings.poolIndex = _newPoolIndex;
    }

    function checkPoolIndex(uint256 index) public view returns (bool) {

        IBooster.PoolInfo memory _pool = IBooster(poolSettings.convexBooster)
            .poolInfo(index);
        return _pool.lptoken == _want;
    }

    function deposit() external override onlyController {

        if (checkPoolIndex(poolSettings.poolIndex)) {
            IERC20 wantToken = IERC20(_want);
            if (
                wantToken.allowance(
                    address(this),
                    poolSettings.convexBooster
                ) == 0
            ) {
                wantToken.approve(poolSettings.convexBooster, uint256(-1));
            }
            IBooster(poolSettings.convexBooster).depositAll(
                poolSettings.poolIndex,
                true
            );
        }
    }

    function getRewards() external override {

        require(
            IRewards(poolSettings.crvRewards).getReward(),
            "!getRewardsCRV"
        );

        ICVXRewards(poolSettings.cvxRewards).getReward(true);
    }

    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {

        IRewards(poolSettings.crvRewards).withdraw(_amount, true);

        require(
            IBooster(poolSettings.convexBooster).withdraw(
                poolSettings.poolIndex,
                _amount
            ),
            "!withdrawSome"
        );

        return _amount;
    }

    function _convertTokens(uint256 _amount) internal{

        IERC20 convertToken = IERC20(poolSettings.crvToken);
        convertToken.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (
            convertToken.allowance(address(this), poolSettings.crvDepositor) == 0
        ) {
            convertToken.approve(poolSettings.crvDepositor, uint256(-1));
        }
        IRewards(poolSettings.crvDepositor).depositAll(true, address(0));
    }

    function convertTokens(uint256 _amount) external {

        _convertTokens(_amount);
        IERC20 _cxvCRV = IERC20(poolSettings.cvxCrvToken);
        uint256 cvxCrvAmount = _cxvCRV.balanceOf(address(this));
        _cxvCRV.safeTransfer(msg.sender, cvxCrvAmount);
    }

    function convertAndStakeTokens(uint256 _amount, uint256 minCurveCvxCrvLPAmount) external {

        _convertTokens(_amount);

	      IERC20 _cvxCrv = IERC20(poolSettings.cvxCrvToken);
        uint256 cvxCrvBalance = _cvxCrv.balanceOf(address(this));
        uint256[2] memory _amounts;
        _amounts[poolSettings.curveCvxCrvIndexInStableSwapPool] = cvxCrvBalance;

        ICurveCvxCrvStableSwap stableSwapPool = ICurveCvxCrvStableSwap(
          poolSettings.curveCvxCrvStableSwapPool
        );

	      _cvxCrv.approve(poolSettings.curveCvxCrvStableSwapPool, cvxCrvBalance);

        uint256 actualCurveCvxCrvLPAmount = stableSwapPool.add_liquidity(
            _amounts,
            minCurveCvxCrvLPAmount,
            address(this)
        );

        IERC20 _stakingToken = IERC20(_want);
        address vault = IController(controller).vaults(_want);
        _stakingToken.approve(vault, actualCurveCvxCrvLPAmount);
        IVaultTransfers(vault).depositFor(actualCurveCvxCrvLPAmount, msg.sender);
    }
}