

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;




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


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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

    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;




contract Base is Initializable, Context, Ownable {

    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {

        Ownable.initialize(_msgSender());
    }

}


pragma solidity ^0.5.12;

contract ModuleNames {

    string internal constant MODULE_ACCESS            = "access";
    string internal constant MODULE_SAVINGS           = "savings";
    string internal constant MODULE_INVESTING         = "investing";
    string internal constant MODULE_STAKING_AKRO      = "staking";
    string internal constant MODULE_STAKING_ADEL      = "stakingAdel";
    string internal constant MODULE_DCA               = "dca";
    string internal constant MODULE_REWARD            = "reward";
    string internal constant MODULE_REWARD_DISTR      = "rewardDistributions";
    string internal constant MODULE_VAULT             = "vault";

    string internal constant TOKEN_AKRO               = "akro";    
    string internal constant TOKEN_ADEL               = "adel";    

    string internal constant CONTRACT_RAY             = "ray";
}


pragma solidity ^0.5.12;



contract Module is Base, ModuleNames {

    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {

        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {

        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){

        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
    }

}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.12;




contract DefiOperatorRole is Initializable, Context {

    using Roles for Roles.Role;

    event DefiOperatorAdded(address indexed account);
    event DefiOperatorRemoved(address indexed account);

    Roles.Role private _operators;

    function initialize(address sender) public initializer {

        if (!isDefiOperator(sender)) {
            _addDefiOperator(sender);
        }
    }

    modifier onlyDefiOperator() {

        require(isDefiOperator(_msgSender()), "DefiOperatorRole: caller does not have the DefiOperator role");
        _;
    }

    function addDefiOperator(address account) public onlyDefiOperator {

        _addDefiOperator(account);
    }

    function renounceDefiOperator() public {

        _removeDefiOperator(_msgSender());
    }

    function isDefiOperator(address account) public view returns (bool) {

        return _operators.has(account);
    }

    function _addDefiOperator(address account) internal {

        _operators.add(account);
        emit DefiOperatorAdded(account);
    }

    function _removeDefiOperator(address account) internal {

        _operators.remove(account);
        emit DefiOperatorRemoved(account);
    }

}


pragma solidity ^0.5.12;

contract IDefiStrategy { 

    function handleDeposit(address token, uint256 amount) external;


    function handleDeposit(address[] calldata tokens, uint256[] calldata amounts) external;


    function withdraw(address beneficiary, address token, uint256 amount) external;


    function withdraw(address beneficiary, uint256[] calldata amounts) external;


    function setVault(address _vault) external;


    function normalizedBalance() external returns(uint256);

    function balanceOf(address token) external returns(uint256);

    function balanceOfAll() external returns(uint256[] memory balances);


    function getStrategyId() external view returns(string memory);

}


pragma solidity ^0.5.12;

interface IStrategyCurveFiSwapCrv {

    event CrvClaimed(string indexed id, address strategy, uint256 amount);

    function curveFiTokenBalance() external view returns(uint256);

    function performStrategyStep1() external;

    function performStrategyStep2(bytes calldata _data, address _token) external;

}


pragma solidity ^0.5.12;

contract IVaultProtocol {

    event DepositToVault(address indexed _user, address indexed _token, uint256 _amount);
    event WithdrawFromVault(address indexed _user, address indexed _token, uint256 _amount);
    event WithdrawRequestCreated(address indexed _user, address indexed _token, uint256 _amount);
    event DepositByOperator(uint256 _amount);
    event WithdrawByOperator(uint256 _amount);
    event WithdrawRequestsResolved(uint256 _totalDeposit, uint256 _totalWithdraw);
    event StrategyRegistered(address indexed _vault, address indexed _strategy, string _id);

    event Claimed(address indexed _vault, address indexed _user, address _token, uint256 _amount);
    event DepositsCleared(address indexed _vault);
    event RequestsCleared(address indexed _vault);


    function registerStrategy(address _strategy) external;


    function depositToVault(address _user, address _token, uint256 _amount) external;

    function depositToVault(address _user, address[] calldata  _tokens, uint256[] calldata _amounts) external;


    function withdrawFromVault(address _user, address _token, uint256 _amount) external;

    function withdrawFromVault(address _user, address[] calldata  _tokens, uint256[] calldata _amounts) external;


    function operatorAction(address _strategy) external returns(uint256, uint256);

    function operatorActionOneCoin(address _strategy, address _token) external returns(uint256, uint256);

    function clearOnHoldDeposits() external;

    function clearWithdrawRequests() external;

    function setRemainder(uint256 _amount, uint256 _index) external;


    function quickWithdraw(address _user, address[] calldata _tokens, uint256[] calldata _amounts) external;

    function quickWithdrawStrategy() external view returns(address);


    function claimRequested(address _user) external;


    function normalizedBalance() external returns(uint256);

    function normalizedBalance(address _strategy) external returns(uint256);

    function normalizedVaultBalance() external view returns(uint256);


    function supportedTokens() external view returns(address[] memory);

    function supportedTokensCount() external view returns(uint256);


    function isStrategyRegistered(address _strategy) external view returns(bool);

    function registeredStrategies() external view returns(address[] memory);


    function isTokenRegistered(address _token) external view returns (bool);

    function tokenRegisteredInd(address _token) external view returns(uint256);


    function totalClaimableAmount(address _token) external view returns (uint256);

    function claimableAmount(address _user, address _token) external view returns (uint256);


    function amountOnHold(address _user, address _token) external view returns (uint256);


    function amountRequested(address _user, address _token) external view returns (uint256);

}


pragma solidity ^0.5.12;

contract ICurveFiDeposit { 

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount) external;

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount, bool donate_dust) external;

    function withdraw_donated_dust() external;


    function coins(int128 i) external view returns (address);

    function underlying_coins (int128 i) external view returns (address);
    function curve() external view returns (address);

    function token() external view returns (address);

    function calc_withdraw_one_coin (uint256 _token_amount, int128 i) external view returns (uint256);
}


pragma solidity ^0.5.12;

contract ICurveFiDeposit_Y { 

    function add_liquidity (uint256[4] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity (uint256 _amount, uint256[4] calldata min_uamounts) external;
    function remove_liquidity_imbalance (uint256[4] calldata uamounts, uint256 max_burn_amount) external;
}


pragma solidity ^0.5.16;

interface ICurveFiLiquidityGauge {

    function lp_token() external returns(address);

    function crv_token() external returns(address);

 
    function balanceOf(address addr) external view returns (uint256);

    function deposit(uint256 _value) external;

    function withdraw(uint256 _value) external;


    function claimable_tokens(address addr) external returns (uint256);

    function minter() external view returns(address); //use minter().mint(gauge_addr) to claim CRV


    function integrate_fraction(address _for) external returns(uint256);

    function user_checkpoint(address _for) external returns(bool);

}


pragma solidity ^0.5.16;

interface ICurveFiMinter {

    function mint(address gauge_addr) external;

    function mint_for(address gauge_addr, address _for) external;

    function minted(address _for, address gauge_addr) external returns(uint256);

}


pragma solidity ^0.5.12;

interface ICurveFiSwap { 

    function balances(int128 i) external view returns(uint256);

    function A() external view returns(uint256);

    function fee() external view returns(uint256);

    function coins(int128 i) external view returns (address);

}


pragma solidity ^0.5.12;

interface IDexag {

    function approvalHandler() external returns(address);


    function trade(
        address from,
        address to,
        uint256 fromAmount,
        address[] calldata exchanges,
        address[] calldata approvals,
        bytes calldata data,
        uint256[] calldata offsets,
        uint256[] calldata etherValues,
        uint256 limitAmount,
        uint256 tradeType
    ) external payable;


}


pragma solidity ^0.5.12;

contract IYErc20 { 


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function deposit(uint256 amount) external;

    function withdraw(uint256 shares) external;

    function getPricePerFullShare() external view returns (uint256);


    function token() external returns(address);


}


pragma solidity ^0.5.0;



contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;



library CalcUtils {

     using SafeMath for uint256;

    function normalizeAmount(address coin, uint256 amount) internal view returns(uint256) {

        uint8 decimals = ERC20Detailed(coin).decimals();
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(uint256(10)**(decimals-18));
        } else if (decimals < 18) {
            return amount.mul(uint256(10)**(18 - decimals));
        }
    }

    function denormalizeAmount(address coin, uint256 amount) internal view returns(uint256) {

        uint256 decimals = ERC20Detailed(coin).decimals();
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(uint256(10)**(decimals-18));
        } else if (decimals < 18) {
            return amount.div(uint256(10)**(18 - decimals));
        }
    }

}


pragma solidity ^0.5.12;


















contract CurveFiStablecoinStrategy is Module, IDefiStrategy, IStrategyCurveFiSwapCrv, DefiOperatorRole {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct PriceData {
        uint256 price;
        uint256 lastUpdateBlock;
    }

    address public vault;

    ICurveFiDeposit public curveFiDeposit;
    IERC20 public curveFiToken;
    ICurveFiLiquidityGauge public curveFiLPGauge;
    ICurveFiSwap public curveFiSwap;
    ICurveFiMinter public curveFiMinter;
    uint256 public slippageMultiplier;
    address public crvToken;
    
    address public dexagProxy;
    address public dexagApproveHandler;

    string internal strategyId;

    mapping(address=>PriceData) internal yPricePerFullShare;

    function initialize(address _pool, string memory _strategyId) public initializer {

        Module.initialize(_pool);
        DefiOperatorRole.initialize(_msgSender());
        slippageMultiplier = 1.01*1e18;
        strategyId = _strategyId;
    }

    function setProtocol(address _depositContract, address _liquidityGauge, address _curveFiMinter, address _dexagProxy) public onlyDefiOperator {

        require(_depositContract != address(0), "Incorrect deposit contract address");

        curveFiDeposit = ICurveFiDeposit(_depositContract);
        curveFiLPGauge = ICurveFiLiquidityGauge(_liquidityGauge);
        curveFiMinter = ICurveFiMinter(_curveFiMinter);
        curveFiSwap = ICurveFiSwap(curveFiDeposit.curve());

        curveFiToken = IERC20(curveFiDeposit.token());

        address lpToken = curveFiLPGauge.lp_token();
        require(lpToken == address(curveFiToken), "CurveFiProtocol: LP tokens do not match");

        crvToken = curveFiLPGauge.crv_token();

        dexagProxy = _dexagProxy;
        dexagApproveHandler = IDexag(_dexagProxy).approvalHandler();
    }

    function setVault(address _vault) public onlyDefiOperator {

        vault = _vault;
    }

    function setDexagProxy(address _dexagProxy) public onlyDefiOperator {

        dexagProxy = _dexagProxy;
        dexagApproveHandler = IDexag(_dexagProxy).approvalHandler();
    }

    function handleDeposit(address token, uint256 amount) public onlyDefiOperator {

        uint256 nTokens = IVaultProtocol(vault).supportedTokensCount();
        uint256[] memory amounts = new uint256[](nTokens);
        uint256 ind = IVaultProtocol(vault).tokenRegisteredInd(token);

        for (uint256 i=0; i < nTokens; i++) {
            amounts[i] = uint256(0);
        }
        IERC20(token).safeTransferFrom(vault, address(this), amount);
        IERC20(token).safeApprove(address(curveFiDeposit), amount);
        amounts[ind] = amount;

        ICurveFiDeposit_Y(address(curveFiDeposit)).add_liquidity(convertArray(amounts), 0);

        uint256 cftBalance = curveFiToken.balanceOf(address(this));
        curveFiToken.safeApprove(address(curveFiLPGauge), cftBalance);
        curveFiLPGauge.deposit(cftBalance);
    }

    function handleDeposit(address[] memory tokens, uint256[] memory amounts) public onlyDefiOperator {

        require(tokens.length == amounts.length, "Count of tokens does not match count of amounts");
        require(amounts.length == IVaultProtocol(vault).supportedTokensCount(), "Amounts count does not match registered tokens");

        for (uint256 i=0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransferFrom(vault, address(this), amounts[i]);
            IERC20(tokens[i]).safeApprove(address(curveFiDeposit), amounts[i]);
        }


        ICurveFiDeposit_Y(address(curveFiDeposit)).add_liquidity(convertArray(amounts), 0);

        uint256 cftBalance = curveFiToken.balanceOf(address(this));
        curveFiToken.safeApprove(address(curveFiLPGauge), cftBalance);
        curveFiLPGauge.deposit(cftBalance);
    }

    function withdraw(address beneficiary, address token, uint256 amount) public onlyDefiOperator {

        uint256 tokenIdx = IVaultProtocol(vault).tokenRegisteredInd(token);


        uint256 nAmount = CalcUtils.normalizeAmount(token, amount);
        uint256 nBalance = normalizedBalance();

        uint256 poolShares = curveFiTokenBalance();
        uint256 withdrawShares = poolShares.mul(nAmount).mul(slippageMultiplier).div(nBalance).div(1e18); //Increase required amount to some percent, so that we definitely have enough to withdraw
        
        uint256 notStaked = curveFiToken.balanceOf(address(this));
        if (notStaked < withdrawShares) { //Use available LP-tokens from previous yield
            curveFiLPGauge.withdraw(withdrawShares.sub(notStaked));
        }

        IERC20(curveFiToken).safeApprove(address(curveFiDeposit), withdrawShares);
        curveFiDeposit.remove_liquidity_one_coin(withdrawShares, int128(tokenIdx), amount, false); //DONATE_DUST - false

        IERC20(token).safeTransfer(beneficiary, amount);
    }

    function withdraw(address beneficiary, uint256[] memory amounts) public onlyDefiOperator {

        address[] memory registeredVaultTokens = IVaultProtocol(vault).supportedTokens();
        require(amounts.length == registeredVaultTokens.length, "Wrong amounts array length");

        uint256 nWithdraw;
        uint256 i;
        for (i = 0; i < registeredVaultTokens.length; i++) {
            address tkn = registeredVaultTokens[i];
            nWithdraw = nWithdraw.add(CalcUtils.normalizeAmount(tkn, amounts[i]));
        }

        uint256 nBalance = normalizedBalance();
        uint256 poolShares = curveFiTokenBalance();
        
        uint256 withdrawShares = poolShares.mul(nWithdraw).mul(slippageMultiplier).div(nBalance).div(1e18); //Increase required amount to some percent, so that we definitely have enough to withdraw

        curveFiLPGauge.withdraw(withdrawShares);

        IERC20(curveFiToken).safeApprove(address(curveFiDeposit), withdrawShares);
        ICurveFiDeposit_Y(address(curveFiDeposit)).remove_liquidity_imbalance(convertArray(amounts), withdrawShares);
        
        for (i = 0; i < registeredVaultTokens.length; i++){
            IERC20 lToken = IERC20(registeredVaultTokens[i]);
            uint256 lBalance = lToken.balanceOf(address(this));
            uint256 lAmount = (lBalance <= amounts[i])?lBalance:amounts[i]; // Rounding may prevent Curve.Fi to return exactly requested amount
            lToken.safeTransfer(beneficiary, lAmount);
        }
    }

    function performStrategyStep1() external onlyDefiOperator {

        claimRewardsFromProtocol();
        uint256 crvAmount = IERC20(crvToken).balanceOf(address(this));

        emit CrvClaimed(strategyId, address(this), crvAmount);
    }
    function performStrategyStep2(bytes calldata dexagSwapData, address swapStablecoin) external onlyDefiOperator {

        uint256 crvAmount = IERC20(crvToken).balanceOf(address(this));
        IERC20(crvToken).safeApprove(dexagApproveHandler, crvAmount);
        (bool success, bytes memory result) = dexagProxy.call(dexagSwapData);
        if(!success) assembly {
            revert(add(result,32), result)  //Reverts with same revert reason
        }
        uint256 amount = IERC20(swapStablecoin).balanceOf(address(this));
        IERC20(swapStablecoin).safeTransfer(vault, amount);
    }

    function curveFiTokenBalance() public view returns(uint256) {

        uint256 notStaked = curveFiToken.balanceOf(address(this));
        uint256 staked = curveFiLPGauge.balanceOf(address(this));
        return notStaked.add(staked);
    }

    function claimRewardsFromProtocol() internal {

        curveFiMinter.mint(address(curveFiLPGauge));
    }

    function balanceOf(address token) public returns(uint256) {

        uint256 tokenIdx = getTokenIndex(token);

        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = curveFiToken.totalSupply();
        uint256 yTokenCurveFiBalance = curveFiSwap.balances(int128(tokenIdx));
        
        uint256 yTokenShares = yTokenCurveFiBalance.mul(cfBalance).div(cfTotalSupply);
        uint256 tokenBalance = getPricePerFullShare(curveFiSwap.coins(int128(tokenIdx))).mul(yTokenShares).div(1e18); //getPricePerFullShare() returns balance of underlying token multiplied by 1e18

        return tokenBalance;
    }

    function balanceOfAll() public returns(uint256[] memory balances) {

        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = curveFiToken.totalSupply();
        uint256 nTokens = IVaultProtocol(vault).supportedTokensCount();

        require(cfTotalSupply > 0, "No Curve pool tokens minted");

        balances = new uint256[](nTokens);

        uint256 ycfBalance;
        for (uint256 i=0; i < nTokens; i++){
            ycfBalance =  curveFiSwap.balances(int128(i));
            uint256 yShares = ycfBalance.mul(cfBalance).div(cfTotalSupply);
            balances[i] = getPricePerFullShare(curveFiSwap.coins(int128(i))).mul(yShares).div(1e18);
        }
    }


    function normalizedBalance() public returns(uint256) {

        address[] memory registeredVaultTokens = IVaultProtocol(vault).supportedTokens();
        uint256[] memory balances = balanceOfAll();

        uint256 summ;
        for (uint256 i=0; i < registeredVaultTokens.length; i++){
            summ = summ.add(CalcUtils.normalizeAmount(registeredVaultTokens[i], balances[i]));
        }
        return summ;
    }

    function getStrategyId() public view returns(string memory) {

        return strategyId;
    }

    function convertArray(uint256[] memory amounts) internal pure returns(uint256[4] memory) {

        require(amounts.length == 4, "Wrong token count");
        uint256[4] memory amnts = [uint256(0), uint256(0), uint256(0), uint256(0)];
        for(uint256 i=0; i < 4; i++){
            amnts[i] = amounts[i];
        }
        return amnts;
    }

    function getTokenIndex(address token) public view returns(uint256) {

        address[] memory registeredVaultTokens = IVaultProtocol(vault).supportedTokens();
        for (uint256 i=0; i < registeredVaultTokens.length; i++){
            if (registeredVaultTokens[i] == token){
                return i;
            }
        }
        revert("CurveFiYProtocol: token not registered");
    }

    function getPricePerFullShare(address yToken) internal returns(uint256) {

        PriceData storage pd = yPricePerFullShare[yToken];
        if(pd.lastUpdateBlock < block.number) {
            pd.price = IYErc20(yToken).getPricePerFullShare();
            pd.lastUpdateBlock = block.number;
        }
        return pd.price;
    }
}