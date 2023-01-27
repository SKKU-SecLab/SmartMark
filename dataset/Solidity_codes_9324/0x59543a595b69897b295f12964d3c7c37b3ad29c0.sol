


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




pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity 0.6.12;


contract Pausable is Context {

    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {

        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {

        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {

        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {

        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused whenNotShutdown {

        paused = false;
        emit Unpaused(_msgSender());
    }

    function _shutdown() internal virtual whenNotShutdown {

        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    function _open() internal virtual whenShutdown {

        stopEverything = false;
        emit Open(_msgSender());
    }
}




pragma solidity 0.6.12;

interface IController {

    function aaveReferralCode() external view returns (uint16);


    function feeCollector(address) external view returns (address);


    function founderFee() external view returns (uint256);


    function founderVault() external view returns (address);


    function interestFee(address) external view returns (uint256);


    function isPool(address) external view returns (bool);


    function pools() external view returns (address);


    function strategy(address) external view returns (address);


    function rebalanceFriction(address) external view returns (uint256);


    function poolRewards(address) external view returns (address);


    function treasuryPool() external view returns (address);


    function uniswapRouter() external view returns (address);


    function withdrawFee(address) external view returns (uint256);

}




pragma solidity 0.6.12;

interface IStrategy {

    function rebalance() external;


    function deposit(uint256 amount) external;


    function beforeWithdraw() external;


    function withdraw(uint256 amount) external;


    function withdrawAll() external;


    function isUpgradable() external view returns (bool);


    function isReservedToken(address _token) external view returns (bool);


    function token() external view returns (address);


    function pool() external view returns (address);


    function totalLocked() external view returns (uint256);


    function pause() external;


    function unpause() external;

}




pragma solidity 0.6.12;


interface IVesperPool is IERC20 {

    function approveToken() external;


    function deposit() external payable;


    function deposit(uint256) external;


    function multiTransfer(uint256[] memory) external returns (bool);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function rebalance() external;


    function resetApproval() external;


    function sweepErc20(address) external;


    function withdraw(uint256) external;


    function withdrawETH(uint256) external;


    function withdrawByStrategy(uint256) external;


    function feeCollector() external view returns (address);


    function getPricePerShare() external view returns (uint256);


    function token() external view returns (address);


    function tokensHere() external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);

}




pragma solidity ^0.6.6;

interface IAddressList {

    event AddressUpdated(address indexed a, address indexed sender);
    event AddressRemoved(address indexed a, address indexed sender);

    function add(address a) external returns (bool);


    function addValue(address a, uint256 v) external returns (bool);


    function addMulti(address[] calldata addrs) external returns (uint256);


    function addValueMulti(address[] calldata addrs, uint256[] calldata values) external returns (uint256);


    function remove(address a) external returns (bool);


    function removeMulti(address[] calldata addrs) external returns (uint256);


    function get(address a) external view returns (uint256);


    function contains(address a) external view returns (bool);


    function at(uint256 index) external view returns (address, uint256);


    function length() external view returns (uint256);

}




pragma solidity ^0.6.6;


interface IAddressListExt is IAddressList {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);


    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}




pragma solidity ^0.6.6;

interface IAddressListFactory {

    event ListCreated(address indexed _sender, address indexed _newList);

    function ours(address a) external view returns (bool);


    function listCount() external view returns (uint256);


    function listAt(uint256 idx) external view returns (address);


    function createList() external returns (address listaddr);

}




pragma solidity 0.6.12;










abstract contract Strategy is IStrategy, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IController public immutable controller;
    IERC20 public immutable collateralToken;
    address public immutable receiptToken;
    address public immutable override pool;
    IAddressListExt public keepers;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 internal constant MAX_UINT_VALUE = uint256(-1);

    constructor(
        address _controller,
        address _pool,
        address _receiptToken
    ) public {
        require(_controller != address(0), "controller-address-is-zero");
        require(IController(_controller).isPool(_pool), "not-a-valid-pool");
        controller = IController(_controller);
        pool = _pool;
        collateralToken = IERC20(IVesperPool(_pool).token());
        receiptToken = _receiptToken;
    }

    modifier live() {
        require(!paused || _msgSender() == address(controller), "contract-has-been-paused");
        _;
    }

    modifier onlyAuthorized() {
        require(
            _msgSender() == address(controller) || _msgSender() == pool,
            "caller-is-not-authorized"
        );
        _;
    }

    modifier onlyController() {
        require(_msgSender() == address(controller), "caller-is-not-the-controller");
        _;
    }

    modifier onlyKeeper() {
        require(keepers.contains(_msgSender()), "caller-is-not-keeper");
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == pool, "caller-is-not-the-pool");
        _;
    }

    function pause() external override onlyController {
        _pause();
    }

    function unpause() external override onlyController {
        _unpause();
    }

    function approveToken() external onlyController {
        _approveToken(0);
        _approveToken(MAX_UINT_VALUE);
    }

    function resetApproval() external onlyController {
        _approveToken(0);
    }

    function createKeeperList() external onlyController {
        require(address(keepers) == address(0), "keeper-list-already-created");
        IAddressListFactory factory =
            IAddressListFactory(0xD57b41649f822C51a73C44Ba0B3da4A880aF0029);
        keepers = IAddressListExt(factory.createList());
        keepers.grantRole(keccak256("LIST_ADMIN"), _msgSender());
    }

    function deposit(uint256 _amount) public override live {
        _updatePendingFee();
        _deposit(_amount);
    }

    function depositAll() external virtual live {
        deposit(collateralToken.balanceOf(pool));
    }

    function withdraw(uint256 _amount) external override onlyAuthorized {
        _updatePendingFee();
        _withdraw(_amount);
    }

    function withdrawAll() external override onlyController {
        _withdrawAll();
    }

    function sweepErc20(address _fromToken) external onlyKeeper {
        require(!isReservedToken(_fromToken), "not-allowed-to-sweep");
        if (_fromToken == ETH) {
            payable(pool).transfer(address(this).balance);
        } else {
            uint256 _amount = IERC20(_fromToken).balanceOf(address(this));
            IERC20(_fromToken).safeTransfer(pool, _amount);
        }
    }

    function isUpgradable() external view override returns (bool) {
        return totalLocked() == 0;
    }

    function token() external view override returns (address) {
        return receiptToken;
    }

    function isReservedToken(address _token) public view virtual override returns (bool);

    function totalLocked() public view virtual override returns (uint256);

    function _handleFee(uint256 _fee) internal virtual {
        if (_fee != 0) {
            IVesperPool(pool).deposit(_fee);
            uint256 _feeInVTokens = IERC20(pool).balanceOf(address(this));
            IERC20(pool).safeTransfer(controller.feeCollector(pool), _feeInVTokens);
        }
    }

    function _deposit(uint256 _amount) internal virtual;

    function _withdraw(uint256 _amount) internal virtual;

    function _approveToken(uint256 _amount) internal virtual;

    function _updatePendingFee() internal virtual;

    function _withdrawAll() internal virtual;
}




pragma solidity 0.6.12;

interface ICollateralManager {

    function addGemJoin(address[] calldata gemJoins) external;


    function mcdManager() external view returns (address);


    function borrow(uint256 vaultNum, uint256 amount) external;


    function depositCollateral(uint256 vaultNum, uint256 amount) external;


    function getVaultBalance(uint256 vaultNum) external view returns (uint256 collateralLocked);


    function getVaultDebt(uint256 vaultNum) external view returns (uint256 daiDebt);


    function getVaultInfo(uint256 vaultNum)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );


    function payback(uint256 vaultNum, uint256 amount) external;


    function registerVault(uint256 vaultNum, bytes32 collateralType) external;


    function vaultOwner(uint256 vaultNum) external returns (address owner);


    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );


    function withdrawCollateral(uint256 vaultNum, uint256 amount) external;

}




pragma solidity 0.6.12;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}




pragma solidity 0.6.12;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}




pragma solidity 0.6.12;




interface ManagerInterface {

    function vat() external view returns (address);


    function open(bytes32, address) external returns (uint256);


    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;

}

interface VatInterface {

    function hope(address) external;


    function nope(address) external;

}

abstract contract MakerStrategy is Strategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    ICollateralManager public immutable cm;
    bytes32 public immutable collateralType;
    uint256 public immutable vaultNum;
    uint256 public lastRebalanceBlock;
    uint256 public highWater;
    uint256 public lowWater;
    uint256 private constant WAT = 10**16;

    constructor(
        address _controller,
        address _pool,
        address _cm,
        address _receiptToken,
        bytes32 _collateralType
    ) public Strategy(_controller, _pool, _receiptToken) {
        collateralType = _collateralType;
        vaultNum = _createVault(_collateralType, _cm);
        cm = ICollateralManager(_cm);
    }

    function beforeWithdraw() external override onlyPool {}

    function withdrawAllWithRebalance() external onlyController {
        _rebalanceEarned();
        _withdrawAll();
    }

    function rebalance() external override onlyKeeper {
        _rebalanceEarned();
        _rebalanceCollateral();
    }

    function rebalanceCollateral() external onlyKeeper {
        _rebalanceCollateral();
    }

    function rebalanceEarned() external onlyKeeper {
        _rebalanceEarned();
    }

    function resurface() external onlyKeeper {
        _resurface();
    }

    function updateBalancingFactor(uint256 _highWater, uint256 _lowWater) external onlyController {
        require(_lowWater != 0, "lowWater-is-zero");
        require(_highWater > _lowWater, "highWater-less-than-lowWater");
        highWater = _highWater.mul(WAT);
        lowWater = _lowWater.mul(WAT);
    }

    function interestEarned() external view virtual returns (uint256) {
        uint256 daiBalance = _getDaiBalance();
        uint256 debt = cm.getVaultDebt(vaultNum);
        if (daiBalance > debt) {
            uint256 daiEarned = daiBalance.sub(debt);
            IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
            address[] memory path = _getPath(DAI, address(collateralToken));
            return uniswapRouter.getAmountsOut(daiEarned, path)[path.length - 1];
        }
        return 0;
    }

    function isReservedToken(address _token) public view virtual override returns (bool) {
        return _token == receiptToken;
    }

    function isUnderwater() public view virtual returns (bool) {
        return cm.getVaultDebt(vaultNum) > _getDaiBalance();
    }

    function totalLocked() public view virtual override returns (uint256) {
        return convertFrom18(cm.getVaultBalance(vaultNum));
    }

    function convertFrom18(uint256 _amount) public pure virtual returns (uint256) {
        return _amount;
    }

    function _createVault(bytes32 _collateralType, address _cm) internal returns (uint256 vaultId) {
        address mcdManager = ICollateralManager(_cm).mcdManager();
        ManagerInterface manager = ManagerInterface(mcdManager);
        vaultId = manager.open(_collateralType, address(this));
        manager.cdpAllow(vaultId, address(this), 1);

        VatInterface(manager.vat()).hope(_cm);
        manager.cdpAllow(vaultId, _cm, 1);

        ICollateralManager(_cm).registerVault(vaultId, _collateralType);
    }

    function _approveToken(uint256 _amount) internal override {
        IERC20(DAI).safeApprove(address(cm), _amount);
        IERC20(DAI).safeApprove(address(receiptToken), _amount);
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        IERC20(DAI).safeApprove(address(uniswapRouter), _amount);
        collateralToken.safeApprove(address(cm), _amount);
        collateralToken.safeApprove(pool, _amount);
        collateralToken.safeApprove(address(uniswapRouter), _amount);
        _afterApproveToken(_amount);
    }

    function _afterApproveToken(uint256 _amount) internal virtual {}

    function _deposit(uint256 _amount) internal override {
        collateralToken.safeTransferFrom(pool, address(this), _amount);
        cm.depositCollateral(vaultNum, _amount);
    }

    function _depositDaiToLender(uint256 _amount) internal virtual;

    function _moveDaiToMaker(uint256 _amount) internal {
        if (_amount != 0) {
            _withdrawDaiFromLender(_amount);
            cm.payback(vaultNum, _amount);
        }
    }

    function _moveDaiFromMaker(uint256 _amount) internal {
        cm.borrow(vaultNum, _amount);
        _amount = IERC20(DAI).balanceOf(address(this));
        _depositDaiToLender(_amount);
    }

    function _rebalanceCollateral() internal {
        _deposit(collateralToken.balanceOf(pool));
        (
            uint256 collateralLocked,
            uint256 debt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        ) = cm.getVaultInfo(vaultNum);
        uint256 maxDebt = collateralLocked.mul(collateralUsdRate).div(highWater);
        if (maxDebt < minimumDebt) {
            _moveDaiToMaker(debt);
        } else {
            if (collateralRatio > highWater) {
                require(!isUnderwater(), "pool-is-underwater");
                _moveDaiFromMaker(maxDebt.sub(debt));
            } else if (collateralRatio < lowWater) {
                _moveDaiToMaker(debt.sub(maxDebt));
            }
        }
    }

    function _rebalanceEarned() internal virtual {
        require(
            (block.number - lastRebalanceBlock) >= controller.rebalanceFriction(pool),
            "can-not-rebalance"
        );
        lastRebalanceBlock = block.number;
        uint256 debt = cm.getVaultDebt(vaultNum);
        _withdrawExcessDaiFromLender(debt);
        uint256 balance = IERC20(DAI).balanceOf(address(this));
        if (balance != 0) {
            IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
            address[] memory path = _getPath(DAI, address(collateralToken));
            try uniswapRouter.getAmountsOut(balance, path) returns (uint256[] memory amounts) {
                if (amounts[path.length - 1] != 0) {
                    uniswapRouter.swapExactTokensForTokens(
                        balance,
                        1,
                        path,
                        address(this),
                        now + 30
                    );
                    uint256 collateralBalance = collateralToken.balanceOf(address(this));
                    uint256 fee = collateralBalance.mul(controller.interestFee(pool)).div(1e18);
                    collateralToken.safeTransfer(pool, collateralBalance.sub(fee));
                    _handleFee(fee);
                }
            } catch {}
        }
    }

    function _resurface() internal {
        uint256 earnBalance = _getDaiBalance();
        uint256 debt = cm.getVaultDebt(vaultNum);
        require(debt > earnBalance, "pool-is-above-water");
        uint256 shortAmount = debt.sub(earnBalance);
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        address[] memory path = _getPath(address(collateralToken), DAI);
        uint256 tokenNeeded = uniswapRouter.getAmountsIn(shortAmount, path)[0];
        if (tokenNeeded != 0) {
            uint256 balance = collateralToken.balanceOf(pool);

            if (balance >= tokenNeeded) {
                collateralToken.safeTransferFrom(pool, address(this), tokenNeeded);
            } else {
                cm.withdrawCollateral(vaultNum, tokenNeeded.sub(balance));
                collateralToken.safeTransferFrom(pool, address(this), balance);
            }
            uniswapRouter.swapExactTokensForTokens(tokenNeeded, 1, path, address(this), now + 30);
            uint256 daiBalance = IERC20(DAI).balanceOf(address(this));
            cm.payback(vaultNum, daiBalance);
        }

        uint256 _collateralbalance = collateralToken.balanceOf(address(this));
        if (_collateralbalance != 0) {
            collateralToken.safeTransfer(pool, _collateralbalance);
        }
    }

    function _withdraw(uint256 _amount) internal override {
        (
            uint256 collateralLocked,
            uint256 debt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        ) = cm.whatWouldWithdrawDo(vaultNum, _amount);
        if (debt != 0 && collateralRatio < lowWater) {
            uint256 maxDebt = collateralLocked.mul(collateralUsdRate).div(highWater);
            if (maxDebt < minimumDebt) {
                _moveDaiToMaker(debt);
            } else if (maxDebt < debt) {
                _moveDaiToMaker(debt.sub(maxDebt));
            }
        }
        cm.withdrawCollateral(vaultNum, _amount);
        collateralToken.safeTransfer(pool, collateralToken.balanceOf(address(this)));
    }

    function _withdrawAll() internal override {
        _moveDaiToMaker(cm.getVaultDebt(vaultNum));
        require(cm.getVaultDebt(vaultNum) == 0, "debt-should-be-0");
        cm.withdrawCollateral(vaultNum, totalLocked());
        collateralToken.safeTransfer(pool, collateralToken.balanceOf(address(this)));
    }

    function _withdrawDaiFromLender(uint256 _amount) internal virtual;

    function _withdrawExcessDaiFromLender(uint256 _base) internal virtual;

    function _getDaiBalance() internal view virtual returns (uint256);

    function _getPath(address _from, address _to) internal pure returns (address[] memory) {
        address[] memory path;
        if (_from == WETH || _to == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = _to;
        }
        return path;
    }

    function _updatePendingFee() internal override {}
}




pragma solidity 0.6.12;


abstract contract VesperMakerStrategy is MakerStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(
        address _controller,
        address _pool,
        address _cm,
        address _vPool,
        bytes32 _collateralType
    ) public MakerStrategy(_controller, _pool, _cm, _vPool, _collateralType) {
        require(IController(_controller).isPool(_vPool), "not-a-valid-vPool");
        require(IVesperPool(_vPool).token() == DAI, "not-a-valid-dai-pool");
    }

    function _getDaiBalance() internal view override returns (uint256) {
        return
            (IVesperPool(receiptToken).getPricePerShare())
                .mul(IVesperPool(receiptToken).balanceOf(address(this)))
                .div(1e18);
    }

    function _depositDaiToLender(uint256 _amount) internal override {
        IVesperPool(receiptToken).deposit(_amount);
    }

    function _withdrawDaiFromLender(uint256 _amount) internal override {
        uint256 vAmount = _amount.mul(1e18).div(IVesperPool(receiptToken).getPricePerShare());
        IVesperPool(receiptToken).withdrawByStrategy(vAmount);
    }

    function _withdrawExcessDaiFromLender(uint256 _base) internal override {
        uint256 balance = _getDaiBalance();
        if (balance > _base) {
            _withdrawDaiFromLender(balance.sub(_base));
        }
    }
}




pragma solidity 0.6.12;


contract VesperMakerStrategyLINK is VesperMakerStrategy {

    string public constant NAME = "Strategy-Vesper-Maker-LINK";
    string public constant VERSION = "2.0.6";

    constructor(
        address _controller,
        address _pool,
        address _cm,
        address _vPool
    ) public VesperMakerStrategy(_controller, _pool, _cm, _vPool, "LINK-A") {}
}