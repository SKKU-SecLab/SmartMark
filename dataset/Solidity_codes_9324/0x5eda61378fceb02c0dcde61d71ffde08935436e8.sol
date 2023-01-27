
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity 0.7.6;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-3.0-or-later

pragma solidity 0.7.6;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// bsl-1.1

pragma solidity 0.7.6;



contract Auth {

    VaultParameters public vaultParameters;

    constructor(address _parameters) {
        vaultParameters = VaultParameters(_parameters);
    }

    modifier onlyManager() {
        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier hasVaultAccess() {
        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}



contract VaultParameters is Auth {

    mapping(address => uint) public stabilityFee;

    mapping(address => uint) public liquidationFee;

    mapping(address => uint) public tokenDebtLimit;

    mapping(address => bool) public canModifyVault;

    mapping(address => bool) public isManager;

    mapping(uint => mapping (address => bool)) public isOracleTypeEnabled;

    address payable public vault;

    address public foundation;

    constructor(address payable _vault, address _foundation) Auth(address(this)) {
        require(_vault != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(_foundation != address(0), "Unit Protocol: ZERO_ADDRESS");

        isManager[msg.sender] = true;
        vault = _vault;
        foundation = _foundation;
    }

    function setManager(address who, bool permit) external onlyManager {
        isManager[who] = permit;
    }

    function setFoundation(address newFoundation) external onlyManager {
        require(newFoundation != address(0), "Unit Protocol: ZERO_ADDRESS");
        foundation = newFoundation;
    }

    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external onlyManager {
        setStabilityFee(asset, stabilityFeeValue);
        setLiquidationFee(asset, liquidationFeeValue);
        setTokenDebtLimit(asset, usdpLimit);
        for (uint i=0; i < oracles.length; i++) {
            setOracleType(oracles[i], asset, true);
        }
    }

    function setVaultAccess(address who, bool permit) external onlyManager {
        canModifyVault[who] = permit;
    }

    function setStabilityFee(address asset, uint newValue) public onlyManager {
        stabilityFee[asset] = newValue;
    }

    function setLiquidationFee(address asset, uint newValue) public onlyManager {
        require(newValue <= 100, "Unit Protocol: VALUE_OUT_OF_RANGE");
        liquidationFee[asset] = newValue;
    }

    function setOracleType(uint _type, address asset, bool enabled) public onlyManager {
        isOracleTypeEnabled[_type][asset] = enabled;
    }

    function setTokenDebtLimit(address asset, uint limit) public onlyManager {
        tokenDebtLimit[asset] = limit;
    }
}// bsl-1.1

pragma solidity 0.7.6;



contract Auth2 {

    VaultParameters public immutable vaultParameters;

    constructor(address _parameters) {
        vaultParameters = VaultParameters(_parameters);
    }

    modifier onlyManager() {
        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier hasVaultAccess() {
        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}// bsl-1.1

pragma solidity ^0.7.6;

interface IVault {
    function DENOMINATOR_1E2 (  ) external view returns ( uint256 );
    function DENOMINATOR_1E5 (  ) external view returns ( uint256 );
    function borrow ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function calculateFee ( address asset, address user, uint256 amount ) external view returns ( uint256 );
    function changeOracleType ( address asset, address user, uint256 newOracleType ) external;
    function chargeFee ( address asset, address user, uint256 amount ) external;
    function col (  ) external view returns ( address );
    function colToken ( address, address ) external view returns ( uint256 );
    function collaterals ( address, address ) external view returns ( uint256 );
    function debts ( address, address ) external view returns ( uint256 );
    function depositCol ( address asset, address user, uint256 amount ) external;
    function depositEth ( address user ) external payable;
    function depositMain ( address asset, address user, uint256 amount ) external;
    function destroy ( address asset, address user ) external;
    function getTotalDebt ( address asset, address user ) external view returns ( uint256 );
    function lastUpdate ( address, address ) external view returns ( uint256 );
    function liquidate ( address asset, address positionOwner, uint256 mainAssetToLiquidator, uint256 colToLiquidator, uint256 mainAssetToPositionOwner, uint256 colToPositionOwner, uint256 repayment, uint256 penalty, address liquidator ) external;
    function liquidationBlock ( address, address ) external view returns ( uint256 );
    function liquidationFee ( address, address ) external view returns ( uint256 );
    function liquidationPrice ( address, address ) external view returns ( uint256 );
    function oracleType ( address, address ) external view returns ( uint256 );
    function repay ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function spawn ( address asset, address user, uint256 _oracleType ) external;
    function stabilityFee ( address, address ) external view returns ( uint256 );
    function tokenDebts ( address ) external view returns ( uint256 );
    function triggerLiquidation ( address asset, address positionOwner, uint256 initialPrice ) external;
    function update ( address asset, address user ) external;
    function usdp (  ) external view returns ( address );
    function vaultParameters (  ) external view returns ( address );
    function weth (  ) external view returns ( address payable );
    function withdrawCol ( address asset, address user, uint256 amount ) external;
    function withdrawEth ( address user, uint256 amount ) external;
    function withdrawMain ( address asset, address user, uint256 amount ) external;
}// bsl-1.1

pragma solidity ^0.7.6;


interface IERC20WithOptional is IERC20  {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}// bsl-1.1

pragma solidity 0.7.6;


interface IWrappedAsset is IERC20 /* IERC20WithOptional */ {

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event PositionMoved(address indexed userFrom, address indexed userTo, uint256 amount);

    function getUnderlyingToken() external view returns (IERC20);

    function deposit(address _userAddr, uint256 _amount) external;

    function withdraw(address _userAddr, uint256 _amount) external;

    function pendingReward(address _userAddr) external view returns (uint256);

    function claimReward(address _userAddr) external;

    function movePosition(address _userAddrFrom, address _userAddrTo, uint256 _amount) external;
}// bsl-1.1

pragma solidity 0.7.6;

interface IBoneLocker {

    function lockInfoByUser(address, uint256) external view returns (uint256, uint256, bool);

    function lockingPeriod() external view returns (uint256);

    function claimAllForUser(uint256 r, address user) external;

    function claimAll(uint256 r) external;

    function getClaimableAmount(address _user) external view returns(uint256);

    function getLeftRightCounters(address _user) external view returns(uint256, uint256);

    function lock(address _holder, uint256 _amount, bool _isDev) external;
    function setLockingPeriod(uint256 _newLockingPeriod, uint256 _newDevLockingPeriod) external;
    function emergencyWithdrawOwner(address _to) external;
}// bsl-1.1

pragma solidity 0.7.6;


interface IBoneToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
}// bsl-1.1

pragma solidity 0.7.6;



interface ITopDog  {

    function bone() external view returns (IBoneToken);
    function boneLocker() external view returns (IBoneLocker);
    function poolInfo(uint256) external view returns (IERC20, uint256, uint256, uint256);
    function poolLength() external view returns (uint256);

    function rewardMintPercent() external view returns (uint256);
    function pendingBone(uint256 _pid, address _user) external view returns (uint256);
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}// bsl-1.1

pragma solidity 0.7.6;


interface ISushiSwapLpToken is IERC20 /* IERC20WithOptional */ {
    function token0() external view returns (address);
    function token1() external view returns (address);
}// bsl-1.1

pragma solidity 0.7.6;



contract WrappedShibaSwapLp is IWrappedAsset, Auth2, ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public constant MULTIPLIER = 1e12;

    IVault public immutable vault;
    ITopDog public immutable topDog;
    uint256 public immutable topDogPoolId;
    IERC20 public immutable boneToken;

    uint256 public lastKnownBonesBalance;
    uint256 public accBonePerShare; // Accumulated BONEs per share, times MULTIPLIER. See below.

    mapping(address => uint256) public rewardDebts;

    modifier updatePool() {
        _updatePool();
        _;
    }

    constructor(
        address _vaultParameters,
        ITopDog _topDog,
        uint256 _topDogPoolId
    )
    Auth2(_vaultParameters)
    ERC20(
        string(
            abi.encodePacked(
                "Wrapped by Unit ",
                getSsLpTokenName(_topDog, _topDogPoolId),
                " ",
                getSsLpTokenToken0Symbol(_topDog, _topDogPoolId),
                "-",
                getSsLpTokenToken1Symbol(_topDog, _topDogPoolId)
            )
        ),
        string(
            abi.encodePacked(
                "wu",
                getSsLpTokenSymbol(_topDog, _topDogPoolId),
                getSsLpTokenToken0Symbol(_topDog, _topDogPoolId),
                getSsLpTokenToken1Symbol(_topDog, _topDogPoolId)
            )
        )
    )
    {
        boneToken = _topDog.bone();
        topDog = _topDog;
        topDogPoolId = _topDogPoolId;
        vault = IVault(VaultParameters(_vaultParameters).vault());

        _setupDecimals(IERC20WithOptional(getSsLpToken(_topDog, _topDogPoolId)).decimals());
    }

    function approveSslpToTopdog() public onlyManager {
        getUnderlyingToken().approve(address(topDog), uint256(-1));
    }

    function deposit(address _userAddr, uint256 _amount) public override nonReentrant updatePool {
        require(msg.sender == _userAddr || vaultParameters.canModifyVault(msg.sender), "Unit Protocol Wrapped Assets: AUTH_FAILED");

        uint256 userBalance = totalBalanceOf(_userAddr);
        _sendPendingRewardInternal(_userAddr, userBalance);

        if (_amount > 0) {
            IERC20 sslpToken = getUnderlyingToken();

            TransferHelper.safeTransferFrom(address(sslpToken), _userAddr, address(this), _amount);

            topDog.deposit(topDogPoolId, _amount);

            _mint(_userAddr, _amount);
        }
        rewardDebts[_userAddr] = (userBalance.add(_amount)).mul(accBonePerShare).div(MULTIPLIER);
        emit Deposit(_userAddr, _amount);
    }

    function withdraw(address _userAddr, uint256 _amount) public override nonReentrant updatePool {
        require(msg.sender == _userAddr || vaultParameters.canModifyVault(msg.sender), "Unit Protocol Wrapped Assets: AUTH_FAILED");

        uint256 userBalance = totalBalanceOf(_userAddr);
        require(userBalance >= _amount, "Unit Protocol Wrapped Assets: INSUFFICIENT_AMOUNT");
        _sendPendingRewardInternal(_userAddr, userBalance);

        if (_amount > 0) {
            IERC20 sslpToken = getUnderlyingToken();

            _burn(_userAddr, _amount);

            topDog.withdraw(topDogPoolId, _amount);

            TransferHelper.safeTransfer(address(sslpToken), _userAddr, _amount);
        }

        rewardDebts[_userAddr] = (userBalance.sub(_amount)).mul(accBonePerShare).div(MULTIPLIER);
        if (totalSupply() == 0) {
            accBonePerShare = 0;
            lastKnownBonesBalance = 0;
        }
        emit Withdraw(_userAddr, _amount);
    }

    function movePosition(address _userAddrFrom, address _userAddrTo, uint256 _amount) public override nonReentrant updatePool hasVaultAccess {
        if (_userAddrFrom == _userAddrTo) {
            _claimRewardInternal(_userAddrFrom);
            return;
        }

        uint256 userFromBalance = totalBalanceOf(_userAddrFrom);
        require(userFromBalance >= _amount, "Unit Protocol Wrapped Assets: INSUFFICIENT_AMOUNT");
        _sendPendingRewardInternal(_userAddrFrom, userFromBalance);

        uint256 userToBalance = totalBalanceOf(_userAddrTo);
        _sendPendingRewardInternal(_userAddrTo, userToBalance);

        rewardDebts[_userAddrFrom] = (userFromBalance.sub(_amount)).mul(accBonePerShare).div(MULTIPLIER);
        rewardDebts[_userAddrTo] = (userToBalance.add(_amount)).mul(accBonePerShare).div(MULTIPLIER);

        emit PositionMoved(_userAddrFrom, _userAddrTo, _amount);
    }

    function pendingReward(address _userAddr) public override view returns (uint256) {
        uint256 lpDeposited = totalSupply();
        if (lpDeposited == 0) {
            return 0;
        }

        uint256 userBalance = totalBalanceOf(_userAddr);
        if (userBalance == 0) {
            return 0;
        }

        uint256 currentBonesBalance = boneToken.balanceOf(address(this));
        uint256 pendingBones = topDog.pendingBone(topDogPoolId, address(this)).mul(topDog.rewardMintPercent()).div(100);
        uint256 addedBones = currentBonesBalance.sub(lastKnownBonesBalance).add(pendingBones);
        uint256 accBonePerShareTemp = accBonePerShare.add(addedBones.mul(MULTIPLIER).div(lpDeposited));

        return userBalance.mul(accBonePerShareTemp).div(MULTIPLIER).sub(rewardDebts[_userAddr]);
    }

    function claimReward(address _userAddr) public override nonReentrant updatePool {
        _claimRewardInternal(_userAddr);
    }

    function _claimRewardInternal(address _userAddr) internal {
        uint256 userBalance = totalBalanceOf(_userAddr);
        _sendPendingRewardInternal(_userAddr, userBalance);
        rewardDebts[_userAddr] = userBalance.mul(accBonePerShare).div(MULTIPLIER);
    }

    function getClaimableRewardAmountFromBoneLockers(address _userAddr, IBoneLocker[] memory _boneLockers) public view returns (uint256)
    {
        uint256 userBalance = totalBalanceOf(_userAddr);
        if (userBalance == 0) {
            return 0;
        }

        uint256 poolReward;
        for (uint256 i = 0; i < _boneLockers.length; ++i) {
            poolReward = poolReward.add(_boneLockers[i].getClaimableAmount(address(this)));
        }

        return poolReward.mul(userBalance).div(totalSupply());
    }

    function claimRewardFromBoneLockers(IBoneLocker[] memory _boneLockers, uint256 _maxBoneLockerRewardsAtOneClaim) public nonReentrant {
        for (uint256 i = 0; i < _boneLockers.length; ++i) {
            (uint256 left, uint256 right) = _boneLockers[i].getLeftRightCounters(address(this));
            if (right > left) {
                if (right - left > _maxBoneLockerRewardsAtOneClaim) {
                    right = left + _maxBoneLockerRewardsAtOneClaim;
                }
                _boneLockers[i].claimAll(right);
            }
        }
    }

    function getBoneLockerRewardsCount(IBoneLocker[] memory _boneLockers) public view returns (uint256[] memory rewards)
    {
        rewards = new uint256[](_boneLockers.length);

        for (uint256 locker_i = 0; locker_i < _boneLockers.length; ++locker_i) {
            IBoneLocker locker = _boneLockers[locker_i];
            (uint256 left, uint256 right) = locker.getLeftRightCounters(address(this));
            uint i;
            for (i = left; i < right; i++) {
                (, uint256 ts,) = locker.lockInfoByUser(address(this), i);
                if (block.timestamp < ts.add(locker.lockingPeriod())) {
                    break;
                }
            }

            rewards[locker_i] = i - left;
        }
    }

    function getUnderlyingToken() public override view returns (IERC20) {
        (IERC20 _sslpToken,,,) = topDog.poolInfo(topDogPoolId);

        return _sslpToken;
    }

    function _updatePool() internal {
        uint256 lpDeposited = totalSupply();
        if (lpDeposited == 0) {
            return;
        }

        topDog.deposit(topDogPoolId, 0);

        uint256 currentBonesBalance = boneToken.balanceOf(address(this));
        uint256 addedBones = currentBonesBalance.sub(lastKnownBonesBalance);
        lastKnownBonesBalance = currentBonesBalance;

        accBonePerShare = accBonePerShare.add(addedBones.mul(MULTIPLIER).div(lpDeposited));
    }

    function _sendPendingRewardInternal(address _userAddr, uint256 _userAmount) internal {
        if (_userAmount == 0) {
            return;
        }

        uint256 userBalance = totalBalanceOf(_userAddr);
        uint256 pending = userBalance.mul(accBonePerShare).div(MULTIPLIER).sub(rewardDebts[_userAddr]);
        if (pending == 0) {
            return;
        }

        _safeBoneTransfer(_userAddr, pending);
        lastKnownBonesBalance = boneToken.balanceOf(address(this));
    }

    function _safeBoneTransfer(address _to, uint256 _amount) internal {
        uint256 boneBal = boneToken.balanceOf(address(this));
        if (_amount > boneBal) {
            boneToken.transfer(_to, boneBal);
        } else {
            boneToken.transfer(_to, _amount);
        }
    }

    function getSsLpToken(ITopDog _topDog, uint256 _topDogPoolId) private view returns (address) {
        (IERC20 _sslpToken,,,) = _topDog.poolInfo(_topDogPoolId);

        return address(_sslpToken);
    }

    function getSsLpTokenSymbol(ITopDog _topDog, uint256 _topDogPoolId) private view returns (string memory) {
        return IERC20WithOptional(getSsLpToken(_topDog, _topDogPoolId)).symbol();
    }

    function getSsLpTokenName(ITopDog _topDog, uint256 _topDogPoolId) private view returns (string memory) {
        return IERC20WithOptional(getSsLpToken(_topDog, _topDogPoolId)).name();
    }

    function getSsLpTokenToken0Symbol(ITopDog _topDog, uint256 _topDogPoolId) private view returns (string memory) {
        return IERC20WithOptional(address(ISushiSwapLpToken(getSsLpToken(_topDog, _topDogPoolId)).token0())).symbol();
    }

    function getSsLpTokenToken1Symbol(ITopDog _topDog, uint256 _topDogPoolId) private view returns (string memory) {
        return IERC20WithOptional(address(ISushiSwapLpToken(getSsLpToken(_topDog, _topDogPoolId)).token1())).symbol();
    }

    function totalBalanceOf(address account) public view returns (uint256) {
        if (account == address(vault)) {
            return 0;
        }
        uint256 collateralsOnVault = vault.collaterals(address(this), account);
        return balanceOf(account).add(collateralsOnVault);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override onlyVault {
        super._transfer(sender, recipient, amount);
    }
}