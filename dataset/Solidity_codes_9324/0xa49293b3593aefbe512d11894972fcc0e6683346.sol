

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}


interface IName {

    function name() external view returns (string memory);

}


interface IPoolFaucet {

    function userStates(address)
        external
        view
        returns (uint128 lastExchangeRateMantissa, uint128 balance);


    function deposit(uint256) external;


    function claim(address) external;

}


interface IPoolTogether {

    function depositTo(
        address,
        uint256,
        address,
        address
    ) external;


    function withdrawInstantlyFrom(
        address,
        uint256,
        address,
        uint256
    ) external;

}


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


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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


interface Uni {

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

}


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


interface VaultAPI is IERC20 {

    function apiVersion() external pure returns (string memory);


    function withdraw(uint256 shares, address recipient) external returns (uint256);


    function token() external view returns (address);


    function strategies(address _strategy) external view returns (StrategyParams memory);


    function creditAvailable() external view returns (uint256);


    function debtOutstanding() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function revokeStrategy() external;


    function governance() external view returns (address);


    function management() external view returns (address);


    function guardian() external view returns (address);

}


abstract contract BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public metadataURI;

    function apiVersion() public pure returns (string memory) {
        return "0.3.2";
    }

    function name() external virtual view returns (string memory);

    function delegatedAssets() external virtual view returns (uint256) {
        return 0;
    }

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedRewards(address rewards);

    event UpdatedMinReportDelay(uint256 delay);

    event UpdatedMaxReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

    uint256 public minReportDelay = 0;

    uint256 public maxReportDelay = 86400; // ~ once a day

    uint256 public profitFactor = 100;

    uint256 public debtThreshold = 0;

    bool public emergencyExit;

    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == keeper ||
                msg.sender == strategist ||
                msg.sender == governance() ||
                msg.sender == vault.guardian() ||
                msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    constructor(address _vault) public {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
    }

    function _initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, uint256(-1)); // Give Vault unlimited access (might save gas)
        strategist = _strategist;
        rewards = _rewards;
        keeper = _keeper;
        vault.approve(rewards, uint256(-1)); // Allow rewards to be pulled
    }

    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

    function setRewards(address _rewards) external onlyStrategist {
        require(_rewards != address(0));
        vault.approve(rewards, 0);
        rewards = _rewards;
        vault.approve(rewards, uint256(-1));
        emit UpdatedRewards(_rewards);
    }

    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

    function governance() internal view returns (address) {
        return vault.governance();
    }

    function estimatedTotalAssets() public virtual view returns (uint256);

    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

    function adjustPosition(uint256 _debtOutstanding) internal virtual;

    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

    function tendTrigger(uint256 callCost) public virtual view returns (bool) {
        return false;
    }

    function tend() external onlyKeepers {
        adjustPosition(vault.debtOutstanding());
    }

    function harvestTrigger(uint256 callCost) public virtual view returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt); // We've earned a profit!

        uint256 credit = vault.creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

    function harvest() external onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
            uint256 totalAssets = estimatedTotalAssets();
            (debtPayment, loss) = liquidatePosition(totalAssets > debtOutstanding ? totalAssets : debtOutstanding);
            if (debtPayment > debtOutstanding) {
                profit = debtPayment.sub(debtOutstanding);
                debtPayment = debtOutstanding;
            }
        } else {
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

        debtOutstanding = vault.report(profit, loss, debtPayment);

        adjustPosition(debtOutstanding);

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
        want.safeTransfer(msg.sender, amountFreed);
    }

    function prepareMigration(address _newStrategy) internal virtual;

    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault) || msg.sender == governance());
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

    function protectedTokens() internal virtual view returns (address[] memory);

    function sweep(address _token) external onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
    }
}


abstract contract BaseStrategyInitializable is BaseStrategy {
    constructor(address _vault) public BaseStrategy(_vault) {}

    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) external {
        _initialize(_vault, _strategist, _rewards, _keeper);
    }
}


contract StrategyDAIPoolTogether is BaseStrategyInitializable {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public wantPool;
    address public poolToken;
    address public unirouter;
    address public bonus;
    address public faucet;
    address public ticket;
    address public refer = address(0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7);

    constructor(address _vault) public BaseStrategyInitializable(_vault) {}

    function _initialize(
        address _wantPool,
        address _poolToken,
        address _unirouter,
        address _bonus,
        address _faucet,
        address _ticket
    ) internal {

        wantPool = _wantPool;
        poolToken = _poolToken;
        unirouter = _unirouter;
        bonus = _bonus;
        faucet = _faucet;
        ticket = _ticket;

        IERC20(want).safeApprove(wantPool, uint256(-1));
        IERC20(poolToken).safeApprove(unirouter, uint256(-1));
        IERC20(bonus).safeApprove(unirouter, uint256(-1));
    }

    function initializeParent(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) public {

        super._initialize(_vault, _strategist, _rewards, _keeper);
    }

    function initialize(
        address _wantPool,
        address _poolToken,
        address _unirouter,
        address _bonus,
        address _faucet,
        address _ticket
    ) external {

        _initialize(
            _wantPool,
            _poolToken,
            _unirouter,
            _bonus,
            _faucet,
            _ticket
        );
    }

    function clone(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _wantPool,
        address _poolToken,
        address _unirouter,
        address _bonus,
        address _faucet,
        address _ticket
    ) external returns (address newStrategy) {

        bytes20 addressBytes = bytes20(address(this));

        assembly {
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            newStrategy := create(0, clone_code, 0x37)
        }

        StrategyDAIPoolTogether(newStrategy).initializeParent(
            _vault,
            _strategist,
            _rewards,
            _keeper
        );
        StrategyDAIPoolTogether(newStrategy).initialize(
            _wantPool,
            _poolToken,
            _unirouter,
            _bonus,
            _faucet,
            _ticket
        );
    }

    function name() external view override returns (string memory) {

        return
            string(
                abi.encodePacked("PoolTogether ", IName(address(want)).name())
            );
    }

    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {

        address[] memory protected = new address[](3);
        protected[0] = ticket;
        protected[1] = poolToken;
        protected[2] = bonus;

        return protected;
    }

    function estimatedTotalAssets() public view override returns (uint256) {

        return balanceOfWant().add(balanceOfPool());
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {

        if (_debtOutstanding > 0) {
            uint256 _amountFreed = 0;
            (_amountFreed, _loss) = liquidatePosition(_debtOutstanding);
            _debtPayment = Math.min(_amountFreed, _debtOutstanding);
        }

        uint256 balanceOfWantBefore = balanceOfWant();
        uint256 debt = vault.strategies(address(this)).totalDebt;

        uint256 currentValue = estimatedTotalAssets();

        if (currentValue > debt) {
            uint256 _amount = currentValue.sub(debt);
            liquidatePosition(_amount);
        }

        claimReward();

        uint256 _tokensAvailable = IERC20(poolToken).balanceOf(address(this));
        if (_tokensAvailable > 0) {
            _swap(_tokensAvailable, address(poolToken));
        }

        uint256 _bonusAvailable = IERC20(bonus).balanceOf(address(this));
        if (_bonusAvailable > 0) {
            _swap(_bonusAvailable, address(bonus));
        }

        uint256 balanceOfWantAfter = balanceOfWant();

        if (balanceOfWantAfter > balanceOfWantBefore) {
            _profit = balanceOfWantAfter.sub(balanceOfWantBefore);
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {

        if (emergencyExit) {
            return;
        }

        if (_debtOutstanding > balanceOfWant()) {
            return;
        }

        uint256 _wantAvailable = balanceOfWant().sub(_debtOutstanding);
        if (_wantAvailable > 0) {
            IPoolTogether(wantPool).depositTo(
                address(this),
                _wantAvailable,
                ticket,
                refer
            );
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {

        if (balanceOfWant() < _amountNeeded) {
            _withdrawSome(_amountNeeded.sub(balanceOfWant()));
        }

        uint256 balanceOfWant = balanceOfWant();

        if (balanceOfWant >= _amountNeeded) {
            _liquidatedAmount = _amountNeeded;
        } else {
            _liquidatedAmount = balanceOfWant;
            _loss = (_amountNeeded.sub(balanceOfWant));
        }
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {

        uint256 balanceOfWantBefore = balanceOfWant();

        IPoolTogether(wantPool).withdrawInstantlyFrom(
            address(this),
            _amount,
            ticket,
            1e20
        );
        uint256 balanceAfter = balanceOfWant();
        return balanceAfter.sub(balanceOfWantBefore);
    }

    function prepareMigration(address _newStrategy) internal override {

        IERC20(poolToken).transfer(
            _newStrategy,
            IERC20(poolToken).balanceOf(address(this))
        );
        IERC20(bonus).transfer(
            _newStrategy,
            IERC20(bonus).balanceOf(address(this))
        );
        IERC20(ticket).transfer(
            _newStrategy,
            IERC20(ticket).balanceOf(address(this))
        );
    }

    function balanceOfPool() public view returns (uint256) {

        return IERC20(ticket).balanceOf(address(this));
    }

    function balanceOfWant() public view returns (uint256) {

        return want.balanceOf(address(this));
    }

    function _swap(uint256 _amountIn, address _token) internal {

        address[] memory path = new address[](3);
        path[0] = _token; // token to swap
        path[1] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // weth
        path[2] = address(want);

        Uni(unirouter).swapExactTokensForTokens(
            _amountIn,
            0,
            path,
            address(this),
            now
        );
    }

    function claimReward() internal {

        IPoolFaucet(faucet).claim(address(this));
    }

    function setReferrer(address _refer) external onlyGovernance {

        refer = _refer;
    }
}