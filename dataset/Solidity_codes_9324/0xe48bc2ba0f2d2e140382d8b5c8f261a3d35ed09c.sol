


pragma solidity 0.5.13;
// pragma experimental ABIEncoderV2;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size != 0;
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "uint mul overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "uint div by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "uint sub overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "uint add overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "uint mod by zero");
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender)
    external
    view
    returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)));
        }
    }
}

library addressMakePayable {

    function makePayable(address x) internal pure returns (address payable) {

        return address(uint160(x));
    }
}

contract IOracle {

    function get(address token) external view returns (uint256, bool);

}

contract IInterestRateModel {

    function getLoanRate(int256 cash, int256 borrow)
    external
    view
    returns (int256 y);


    function getDepositRate(int256 cash, int256 borrow)
    external
    view
    returns (int256 y);


    function calculateBalance(
        int256 principal,
        int256 lastIndex,
        int256 newIndex
    ) external view returns (int256 y);


    function calculateInterestIndex(
        int256 Index,
        int256 r,
        int256 t
    ) external view returns (int256 y);


    function pert(
        int256 principal,
        int256 r,
        int256 t
    ) external view returns (int256 y);


    function getNewReserve(
        int256 oldReserve,
        int256 cash,
        int256 borrow,
        int256 blockDelta
    ) external view returns (int256 y);

}

contract PoolPawn is ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using addressMakePayable for address;

    uint public constant int_max = 57896044618658097711785492504343953926634992332820282019728792003956564819967;

    address public admin; //the admin address
    address public proposedAdmin; //use pull over push pattern for admin


    struct Balance {
        uint256 principal;
        uint256 interestIndex;
        uint256 totalPnl; //total profit and loss
    }

    struct Market {
        uint256 accrualBlockNumber;
        int256 supplyRate; //存款利率
        int256 demondRate; //借款利率
        IInterestRateModel irm;
        uint256 totalSupply;
        uint256 supplyIndex;
        uint256 totalBorrows;
        uint256 borrowIndex;
        uint256 totalReserves; //系统盈利
        uint256 minPledgeRate; //最小质押率
        uint256 liquidationDiscount; //清算折扣
        uint256 decimals; //币种的最小精度
    }

    mapping(address => mapping(address => Balance))
    public accountSupplySnapshot; //tokenContract->address(usr)->SupplySnapshot
    mapping(address => mapping(address => Balance))
    public accountBorrowSnapshot; //tokenContract->address(usr)->BorrowSnapshot

    struct LiquidateInfo {
        address targetAccount; //被清算账户
        address liquidator; //清算人
        address assetCollatera; //抵押物token地址
        address assetBorrow; //债务token地址
        uint256 liquidateAmount; //清算额度，抵押物
        uint256 targetAmount; //目标额度, 债务
        uint256 timestamp;
    }

    mapping(uint256 => LiquidateInfo) public liquidateInfoMap;
    uint256 public liquidateIndexes;

    function setLiquidateInfoMap(
        address _targetAccount,
        address _liquidator,
        address _assetCollatera,
        address _assetBorrow,
        uint256 x,
        uint256 y
    ) internal {

        LiquidateInfo memory newStruct = LiquidateInfo(
            _targetAccount,
            _liquidator,
            _assetCollatera,
            _assetBorrow,
            x,
            y,
            block.timestamp
        );
        liquidateInfoMap[liquidateIndexes] = newStruct;
        liquidateIndexes++;
    }

    mapping(uint256 => address) public accounts;
    mapping(address => uint256) public indexes;
    uint256 public index = 1;

    function join(address who) internal {

        if (indexes[who] == 0) {
            accounts[index] = who;
            indexes[who] = index;
            ++index;
        }
    }

    event SupplyPawnLog(
        address usr,
        address t,
        uint256 amount,
        uint256 beg,
        uint256 end
    );
    event WithdrawPawnLog(
        address usr,
        address t,
        uint256 amount,
        uint256 beg,
        uint256 end
    );
    event BorrowPawnLog(
        address usr,
        address t,
        uint256 amount,
        uint256 beg,
        uint256 end
    );
    event RepayFastBorrowLog(
        address usr,
        address t,
        uint256 amount,
        uint256 beg,
        uint256 end
    );
    event LiquidateBorrowPawnLog(
        address usr,
        address tBorrow,
        uint256 endBorrow,
        address liquidator,
        address tCol,
        uint256 endCol
    );
    event WithdrawPawnEquityLog(
        address t,
        uint256 equityAvailableBefore,
        uint256 amount,
        address owner
    );

    mapping(address => Market) public mkts; //tokenAddress->Market
    address[] public collateralTokens; //抵押币种
    IOracle public oracleInstance;

    uint256 public constant initialInterestIndex = 10**18;
    uint256 public constant defaultOriginationFee = 0; // default is zero bps
    uint256 public constant originationFee = 0;
    uint256 public constant ONE_ETH = 1 ether;

    function addCollateralMarket(address asset) public onlyAdmin {

        for (uint256 i = 0; i < collateralTokens.length; i++) {
            if (collateralTokens[i] == asset) {
                return;
            }
        }
        collateralTokens.push(asset);
    }

    function getCollateralMarketsLength() external view returns (uint256) {

        return collateralTokens.length;
    }

    function setInterestRateModel(address t, address irm) public onlyAdmin {

        mkts[t].irm = IInterestRateModel(irm);
    }

    function setMinPledgeRate(address t, uint256 minPledgeRate)
    external
    onlyAdmin
    {

        mkts[t].minPledgeRate = minPledgeRate;
    }

    function setLiquidationDiscount(address t, uint256 liquidationDiscount)
    external
    onlyAdmin
    {

        mkts[t].liquidationDiscount = liquidationDiscount;
    }

    function initCollateralMarket(
        address t,
        address irm,
        address oracle,
        uint256 decimals
    ) external onlyAdmin {

        if (address(oracleInstance) == address(0)) {
            setOracle(oracle);
        }
        Market memory m = mkts[t];
        if (address(m.irm) == address(0)) {
            setInterestRateModel(t, irm);
        }

        addCollateralMarket(t);
        if (m.supplyIndex == 0) {
            m.supplyIndex = initialInterestIndex;
        }

        if (m.borrowIndex == 0) {
            m.borrowIndex = initialInterestIndex;
        }

        if (m.decimals == 0) {
            m.decimals = decimals;
        }
        mkts[t] = m;
    }

    constructor() public {
        admin = msg.sender;
    }


    modifier onlyAdmin() {

        require(msg.sender == admin, "only admin can do this!");
        _;
    }

    function proposeNewAdmin(address admin_) external onlyAdmin {

        proposedAdmin = admin_;
    }

    function claimAdministration() external {

        require(msg.sender == proposedAdmin, "Not proposed admin.");
        admin = proposedAdmin;
        proposedAdmin = address(0);
    }

    function setInitialTimestamp(address token) external onlyAdmin {

        mkts[token].accrualBlockNumber = now;
    }

    function setDecimals(address t, uint256 decimals) external onlyAdmin {

        mkts[t].decimals = decimals;
    }

    function setOracle(address oracle) public onlyAdmin {

        oracleInstance = IOracle(oracle);
    }

    modifier existOracle() {

        require(address(oracleInstance) != address(0), "oracle not set");
        _;
    }

    function fetchAssetPrice(address asset)
    public
    view
    returns (uint256, bool)
    {

        require(address(oracleInstance) != address(0), "oracle not set");
        return oracleInstance.get(asset);
    }

    function valid_uint(uint r) internal view returns (int256) {

        require(r <= int_max, "uint r is not valid");
        return int256(r);
    }

    function getPriceForAssetAmount(address asset, uint256 assetAmount)
    public
    view
    returns (uint256)
    {

        require(address(oracleInstance) != address(0), "oracle not set");
        (uint256 price, bool ok) = fetchAssetPrice(asset);
        require(ok && price != 0, "invalid token price");
        return price.mul(assetAmount).div(10**mkts[asset].decimals);
    }

    function getAssetAmountForValue(address t, uint256 usdValue)
    public
    view
    returns (uint256)
    {

        require(address(oracleInstance) != address(0), "oracle not set");
        (uint256 price, bool ok) = fetchAssetPrice(t);
        require(ok && price != 0, "invalid token price");
        return usdValue.mul(10**mkts[t].decimals).div(price);
    }

    function getCash(address t) public view returns (uint256) {

        if (t == address(0)) {
            return address(this).balance;
        }
        IERC20 token = IERC20(t);
        return token.balanceOf(address(this));
    }

    function getBalanceOf(address asset, address from)
    internal
    view
    returns (uint256)
    {

        if (asset == address(0)) {
            return address(from).balance;
        }

        IERC20 token = IERC20(asset);

        return token.balanceOf(from);
    }

    function loanToDepositRatio(address asset) public view returns (uint256) {

        uint256 loan = mkts[asset].totalBorrows;
        uint256 deposit = mkts[asset].totalSupply;

        return loan.mul(ONE_ETH).div(deposit);
    }

    function getSupplyBalance(address acc, address t)
    public
    view
    returns (uint256)
    {

        Balance storage supplyBalance = accountSupplySnapshot[t][acc];

        int256 mSupplyIndex = mkts[t].irm.pert(
            int256(mkts[t].supplyIndex),
            mkts[t].supplyRate,
            int256(now - mkts[t].accrualBlockNumber)
        );

        uint256 userSupplyCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(supplyBalance.principal),
                int256(supplyBalance.interestIndex),
                mSupplyIndex
            )
        );
        return userSupplyCurrent;
    }

    function getSupplyBalanceInUSD(address who, address t)
    public
    view
    returns (uint256)
    {

        return getPriceForAssetAmount(t, getSupplyBalance(who, t));
    }

    function getSupplyPnl(address acc, address t)
    public
    view
    returns (uint256)
    {

        Balance storage supplyBalance = accountSupplySnapshot[t][acc];

        int256 mSupplyIndex = mkts[t].irm.pert(
            int256(mkts[t].supplyIndex),
            mkts[t].supplyRate,
            int256(now - mkts[t].accrualBlockNumber)
        );

        uint256 userSupplyCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(supplyBalance.principal),
                int256(supplyBalance.interestIndex),
                mSupplyIndex
            )
        );

        if (userSupplyCurrent > supplyBalance.principal) {
            return
            supplyBalance.totalPnl.add(
                userSupplyCurrent.sub(supplyBalance.principal)
            );
        } else {
            return supplyBalance.totalPnl;
        }
    }

    function getSupplyPnlInUSD(address who, address t)
    public
    view
    returns (uint256)
    {

        return getPriceForAssetAmount(t, getSupplyPnl(who, t));
    }

    function getTotalSupplyPnl(address who)
    public
    view
    returns (uint256 sumPnl)
    {

        uint256 length = collateralTokens.length;

        for (uint256 i = 0; i < length; i++) {
            uint256 pnl = getSupplyPnlInUSD(who, collateralTokens[i]);
            sumPnl = sumPnl.add(pnl);
        }
    }

    function getBorrowBalance(address acc, address t)
    public
    view
    returns (uint256)
    {

        Balance storage borrowBalance = accountBorrowSnapshot[t][acc];

        int256 mBorrowIndex = mkts[t].irm.pert(
            int256(mkts[t].borrowIndex),
            mkts[t].demondRate,
            int256(now - mkts[t].accrualBlockNumber)
        );

        uint256 userBorrowCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(borrowBalance.principal),
                int256(borrowBalance.interestIndex),
                mBorrowIndex
            )
        );
        return userBorrowCurrent;
    }

    function getBorrowBalanceInUSD(address who, address t)
    public
    view
    returns (uint256)
    {

        return getPriceForAssetAmount(t, getBorrowBalance(who, t));
    }

    function getBorrowPnl(address acc, address t)
    public
    view
    returns (uint256)
    {

        Balance storage borrowBalance = accountBorrowSnapshot[t][acc];

        int256 mBorrowIndex = mkts[t].irm.pert(
            int256(mkts[t].borrowIndex),
            mkts[t].demondRate,
            int256(now - mkts[t].accrualBlockNumber)
        );

        uint256 userBorrowCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(borrowBalance.principal),
                int256(borrowBalance.interestIndex),
                mBorrowIndex
            )
        );

        return
        borrowBalance.totalPnl.add(userBorrowCurrent).sub(
            borrowBalance.principal
        );
    }

    function getBorrowPnlInUSD(address who, address t)
    public
    view
    returns (uint256)
    {

        return getPriceForAssetAmount(t, getBorrowPnl(who, t));
    }

    function getTotalBorrowPnl(address who)
    public
    view
    returns (uint256 sumPnl)
    {

        uint256 length = collateralTokens.length;

        for (uint256 i = 0; i < length; i++) {
            uint256 pnl = getBorrowPnlInUSD(who, collateralTokens[i]);
            sumPnl = sumPnl.add(pnl);
        }
    }

    function getBorrowBalanceLeverage(address who, address t)
    public
    view
    returns (uint256)
    {

        return
        getBorrowBalanceInUSD(who, t).mul(mkts[t].minPledgeRate).div(
            ONE_ETH
        );
    }

    function calcAccountTokenValuesInternal(address who, address t)
    public
    view
    returns (uint256, uint256)
    {

        return (getSupplyBalanceInUSD(who, t), getBorrowBalanceInUSD(who, t));
    }

    function calcAccountTokenValuesLeverageInternal(address who, address t)
    public
    view
    returns (uint256, uint256)
    {

        return (
        getSupplyBalanceInUSD(who, t),
        getBorrowBalanceLeverage(who, t)
        );
    }

    function calcAccountAllTokenValuesLeverageInternal(address who)
    public
    view
    returns (uint256 sumSupplies, uint256 sumBorrowLeverage)
    {

        uint256 length = collateralTokens.length;

        for (uint256 i = 0; i < length; i++) {
            (
            uint256 supplyValue,
            uint256 borrowsLeverage
            ) = calcAccountTokenValuesLeverageInternal(
                who,
                collateralTokens[i]
            );
            sumSupplies = sumSupplies.add(supplyValue);
            sumBorrowLeverage = sumBorrowLeverage.add(borrowsLeverage);
        }
    }

    function calcAccountLiquidity(address who)
    public
    view
    returns (uint256, uint256)
    {

        uint256 sumSupplies;
        uint256 sumBorrowsLeverage; //sumBorrows* collateral ratio
        (
        sumSupplies,
        sumBorrowsLeverage
        ) = calcAccountAllTokenValuesLeverageInternal(who);
        if (sumSupplies < sumBorrowsLeverage) {
            return (0, sumBorrowsLeverage.sub(sumSupplies)); //不足
        } else {
            return (sumSupplies.sub(sumBorrowsLeverage), 0); //有余
        }
    }

    struct SupplyIR {
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newBorrowIndex;
    }

    function supplyPawn(address t, uint256 amount)
    external
    payable
    nonReentrant
    {

        uint256 supplyAmount = amount;
        if (t == address(0)) {
            require(amount == msg.value, "Eth value should be equal to amount");
            supplyAmount = msg.value;
        } else {
            require(msg.value == 0, "Eth should not be provided");
        }
        SupplyIR memory tmp;
        Market storage market = mkts[t];
        Balance storage supplyBalance = accountSupplySnapshot[t][msg.sender];

        uint256 lastTimestamp = market.accrualBlockNumber;
        uint256 blockDelta = now - lastTimestamp;

        tmp.newSupplyIndex = uint256(
            market.irm.pert(
                int256(market.supplyIndex),
                market.supplyRate,
                int256(blockDelta)
            )
        );
        tmp.userSupplyCurrent = uint256(
            market.irm.calculateBalance(
                valid_uint(accountSupplySnapshot[t][msg.sender].principal),
                int256(supplyBalance.interestIndex),
                int256(tmp.newSupplyIndex)
            )
        );
        tmp.userSupplyUpdated = tmp.userSupplyCurrent.add(supplyAmount);
        tmp.newTotalSupply = market.totalSupply.add(tmp.userSupplyUpdated).sub(
            supplyBalance.principal
        );

        tmp.currentCash = getCash(t);
        tmp.updatedCash = t != address(0)
        ? tmp.currentCash.add(supplyAmount)
        : tmp.currentCash;

        market.supplyRate = market.irm.getDepositRate(
            valid_uint(tmp.updatedCash),
            valid_uint(market.totalBorrows)
        );
        tmp.newBorrowIndex = uint256(
            market.irm.pert(
                int256(market.borrowIndex),
                market.demondRate,
                int256(blockDelta)
            )
        );
        market.demondRate = market.irm.getLoanRate(
            valid_uint(tmp.updatedCash),
            valid_uint(market.totalBorrows)
        );

        market.borrowIndex = tmp.newBorrowIndex;
        market.supplyIndex = tmp.newSupplyIndex;
        market.totalSupply = tmp.newTotalSupply;
        market.accrualBlockNumber = now;
        tmp.startingBalance = supplyBalance.principal;
        supplyBalance.principal = tmp.userSupplyUpdated;
        supplyBalance.interestIndex = tmp.newSupplyIndex;

        if (tmp.userSupplyCurrent > tmp.startingBalance) {
            supplyBalance.totalPnl = supplyBalance.totalPnl.add(
                tmp.userSupplyCurrent.sub(tmp.startingBalance)
            );
        }

        join(msg.sender);

        safeTransferFrom(
            t,
            msg.sender,
            address(this),
            address(this).makePayable(),
            supplyAmount,
            0
        );

        emit SupplyPawnLog(
            msg.sender,
            t,
            supplyAmount,
            tmp.startingBalance,
            tmp.userSupplyUpdated
        );
    }

    struct WithdrawIR {
        uint256 withdrawAmount;
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newBorrowIndex;
        uint256 accountLiquidity;
        uint256 accountShortfall;
        uint256 usdValueOfWithdrawal;
        uint256 withdrawCapacity;
    }

    function withdrawPawn(address t, uint256 requestedAmount)
    external
    nonReentrant
    {

        Market storage market = mkts[t];
        Balance storage supplyBalance = accountSupplySnapshot[t][msg.sender];

        WithdrawIR memory tmp;

        uint256 lastTimestamp = mkts[t].accrualBlockNumber;
        uint256 blockDelta = now - lastTimestamp;

        (tmp.accountLiquidity, tmp.accountShortfall) = calcAccountLiquidity(
            msg.sender
        );
        require(
            tmp.accountLiquidity != 0 && tmp.accountShortfall == 0,
            "can't withdraw, shortfall"
        );
        tmp.newSupplyIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].supplyIndex),
                mkts[t].supplyRate,
                int256(blockDelta)
            )
        );
        tmp.userSupplyCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(supplyBalance.principal),
                int256(supplyBalance.interestIndex),
                int256(tmp.newSupplyIndex)
            )
        );

        tmp.currentCash = getCash(t);
        if (requestedAmount == uint256(-1)) {
            tmp.withdrawCapacity = getAssetAmountForValue(
                t,
                tmp.accountLiquidity
            );
            tmp.withdrawAmount = min(
                min(tmp.withdrawCapacity, tmp.userSupplyCurrent),
                tmp.currentCash
            );
        } else {
            tmp.withdrawAmount = requestedAmount;
        }

        tmp.updatedCash = tmp.currentCash.sub(tmp.withdrawAmount);
        tmp.userSupplyUpdated = tmp.userSupplyCurrent.sub(tmp.withdrawAmount);

        tmp.usdValueOfWithdrawal = getPriceForAssetAmount(
            t,
            tmp.withdrawAmount
        );
        require(
            tmp.usdValueOfWithdrawal <= tmp.accountLiquidity,
            "account is short"
        );

        tmp.newTotalSupply = market.totalSupply.add(tmp.userSupplyUpdated).sub(
            supplyBalance.principal
        );

        tmp.newSupplyIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].supplyIndex),
                mkts[t].supplyRate,
                int256(blockDelta)
            )
        );

        market.supplyRate = mkts[t].irm.getDepositRate(
            valid_uint(tmp.updatedCash),
            valid_uint(market.totalBorrows)
        );
        tmp.newBorrowIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].borrowIndex),
                mkts[t].demondRate,
                int256(blockDelta)
            )
        );
        market.demondRate = mkts[t].irm.getLoanRate(
            valid_uint(tmp.updatedCash),
            valid_uint(market.totalBorrows)
        );

        market.accrualBlockNumber = now;
        market.totalSupply = tmp.newTotalSupply;
        market.supplyIndex = tmp.newSupplyIndex;
        market.borrowIndex = tmp.newBorrowIndex;
        tmp.startingBalance = supplyBalance.principal;
        supplyBalance.principal = tmp.userSupplyUpdated;
        supplyBalance.interestIndex = tmp.newSupplyIndex;

        safeTransferFrom(
            t,
            address(this).makePayable(),
            address(this),
            msg.sender,
            tmp.withdrawAmount,
            0
        );

        emit WithdrawPawnLog(
            msg.sender,
            t,
            tmp.withdrawAmount,
            tmp.startingBalance,
            tmp.userSupplyUpdated
        );
    }

    struct PayBorrowIR {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 repayAmount;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 startingBalance;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function calcBorrowAmountWithFee(uint256 borrowAmount)
    public
    pure
    returns (uint256)
    {

        return borrowAmount.mul((ONE_ETH).add(originationFee)).div(ONE_ETH);
    }

    function getPriceForAssetAmountMulCollatRatio(
        address t,
        uint256 assetAmount
    ) public view returns (uint256) {

        return
        getPriceForAssetAmount(t, assetAmount)
        .mul(mkts[t].minPledgeRate)
        .div(ONE_ETH);
    }

    struct BorrowIR {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 borrowAmountWithFee;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 startingBalance;
        uint256 accountLiquidity;
        uint256 accountShortfall;
        uint256 usdValueOfBorrowAmountWithFee;
    }

    function BorrowPawn(address t, uint256 amount) external nonReentrant {

        BorrowIR memory tmp;
        Market storage market = mkts[t];
        Balance storage borrowBalance = accountBorrowSnapshot[t][msg.sender];

        uint256 lastTimestamp = mkts[t].accrualBlockNumber;
        uint256 blockDelta = now - lastTimestamp;

        tmp.newBorrowIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].borrowIndex),
                mkts[t].demondRate,
                int256(blockDelta)
            )
        );
        int256 lastIndex = int256(borrowBalance.interestIndex);
        tmp.userBorrowCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(borrowBalance.principal),
                lastIndex,
                int256(tmp.newBorrowIndex)
            )
        );
        tmp.borrowAmountWithFee = calcBorrowAmountWithFee(amount);

        tmp.userBorrowUpdated = tmp.userBorrowCurrent.add(
            tmp.borrowAmountWithFee
        );
        tmp.newTotalBorrows = market
        .totalBorrows
        .add(tmp.userBorrowUpdated)
        .sub(borrowBalance.principal);

        (tmp.accountLiquidity, tmp.accountShortfall) = calcAccountLiquidity(
            msg.sender
        );
        require(
            tmp.accountLiquidity != 0 && tmp.accountShortfall == 0,
            "can't borrow, shortfall"
        );

        tmp.usdValueOfBorrowAmountWithFee = getPriceForAssetAmountMulCollatRatio(
            t,
            tmp.borrowAmountWithFee
        );
        require(
            tmp.usdValueOfBorrowAmountWithFee <= tmp.accountLiquidity,
            "can't borrow, without enough value"
        );

        tmp.currentCash = getCash(t);
        tmp.updatedCash = tmp.currentCash.sub(amount);

        tmp.newSupplyIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].supplyIndex),
                mkts[t].supplyRate,
                int256(blockDelta)
            )
        );
        market.supplyRate = mkts[t].irm.getDepositRate(
            valid_uint(tmp.updatedCash),
            valid_uint(tmp.newTotalBorrows)
        );
        market.demondRate = mkts[t].irm.getLoanRate(
            valid_uint(tmp.updatedCash),
            valid_uint(tmp.newTotalBorrows)
        );

        market.accrualBlockNumber = now;
        market.totalBorrows = tmp.newTotalBorrows;
        market.supplyIndex = tmp.newSupplyIndex;
        market.borrowIndex = tmp.newBorrowIndex;
        tmp.startingBalance = borrowBalance.principal;
        borrowBalance.principal = tmp.userBorrowUpdated;
        borrowBalance.interestIndex = tmp.newBorrowIndex;


        safeTransferFrom(
            t,
            address(this).makePayable(),
            address(this),
            msg.sender,
            amount,
            0
        );

        emit BorrowPawnLog(
            msg.sender,
            t,
            amount,
            tmp.startingBalance,
            tmp.userBorrowUpdated
        );
    }

    function repayFastBorrow(address t, uint256 amount)
    external
    payable
    nonReentrant
    {

        PayBorrowIR memory tmp;
        Market storage market = mkts[t];
        Balance storage borrowBalance = accountBorrowSnapshot[t][msg.sender];

        uint256 lastTimestamp = mkts[t].accrualBlockNumber;
        uint256 blockDelta = now - lastTimestamp;

        tmp.newBorrowIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].borrowIndex),
                mkts[t].demondRate,
                int256(blockDelta)
            )
        );

        int256 lastIndex = int256(borrowBalance.interestIndex);
        tmp.userBorrowCurrent = uint256(
            mkts[t].irm.calculateBalance(
                valid_uint(borrowBalance.principal),
                lastIndex,
                int256(tmp.newBorrowIndex)
            )
        );

        if (amount == uint256(-1)) {
            tmp.repayAmount = min(
                getBalanceOf(t, msg.sender),
                tmp.userBorrowCurrent
            );
            if (t == address(0)) {
                require(
                    msg.value > tmp.repayAmount,
                    "Eth value should be larger than repayAmount"
                );
            }
        } else {
            tmp.repayAmount = amount;
            if (t == address(0)) {
                require(
                    msg.value == tmp.repayAmount,
                    "Eth value should be equal to repayAmount"
                );
            }
        }

        tmp.userBorrowUpdated = tmp.userBorrowCurrent.sub(tmp.repayAmount);
        tmp.newTotalBorrows = market
        .totalBorrows
        .add(tmp.userBorrowUpdated)
        .sub(borrowBalance.principal);
        tmp.currentCash = getCash(t);
        tmp.updatedCash = t != address(0)
        ? tmp.currentCash.add(tmp.repayAmount)
        : tmp.currentCash;

        tmp.newSupplyIndex = uint256(
            mkts[t].irm.pert(
                int256(mkts[t].supplyIndex),
                mkts[t].supplyRate,
                int256(blockDelta)
            )
        );
        market.supplyRate = mkts[t].irm.getDepositRate(
            valid_uint(tmp.updatedCash),
            valid_uint(tmp.newTotalBorrows)
        );
        market.demondRate = mkts[t].irm.getLoanRate(
            valid_uint(tmp.updatedCash),
            valid_uint(tmp.newTotalBorrows)
        );

        market.accrualBlockNumber = now;
        market.totalBorrows = tmp.newTotalBorrows;
        market.supplyIndex = tmp.newSupplyIndex;
        market.borrowIndex = tmp.newBorrowIndex;
        tmp.startingBalance = borrowBalance.principal;
        borrowBalance.principal = tmp.userBorrowUpdated;
        borrowBalance.interestIndex = tmp.newBorrowIndex;

        safeTransferFrom(
            t,
            msg.sender,
            address(this),
            address(this).makePayable(),
            tmp.repayAmount,
            msg.value
        );

        emit RepayFastBorrowLog(
            msg.sender,
            t,
            tmp.repayAmount,
            tmp.startingBalance,
            tmp.userBorrowUpdated
        );

    }

    function calcDiscountedRepayToEvenAmount(
        address targetAccount,
        address underwaterAsset,
        uint256 underwaterAssetPrice
    ) public view returns (uint256) {

        (, uint256 shortfall) = calcAccountLiquidity(targetAccount);
        uint256 minPledgeRate = mkts[underwaterAsset].minPledgeRate;
        uint256 liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
        uint256 gap = minPledgeRate.sub(liquidationDiscount).sub(1 ether);
        return
        shortfall.mul(10**mkts[underwaterAsset].decimals).div(
            underwaterAssetPrice.mul(gap).div(ONE_ETH)
        ); //underwater asset amount
    }

    function calcDiscountedBorrowDenominatedCollateral(
        address underwaterAsset,
        address collateralAsset,
        uint256 underwaterAssetPrice,
        uint256 collateralPrice,
        uint256 supplyCurrent_TargetCollateralAsset
    ) public view returns (uint256 res) {

        uint256 liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
        uint256 onePlusLiquidationDiscount = (ONE_ETH).add(liquidationDiscount);
        uint256 supplyCurrentTimesOracleCollateral
        = supplyCurrent_TargetCollateralAsset.mul(collateralPrice);

        res = supplyCurrentTimesOracleCollateral.div(
            onePlusLiquidationDiscount.mul(underwaterAssetPrice).div(ONE_ETH)
        ); //underwaterAsset amout
        res = res.mul(10**mkts[underwaterAsset].decimals);
        res = res.div(10**mkts[collateralAsset].decimals);
    }

    function calcAmountSeize(
        address underwaterAsset,
        address collateralAsset,
        uint256 underwaterAssetPrice,
        uint256 collateralPrice,
        uint256 closeBorrowAmount_TargetUnderwaterAsset
    ) public view returns (uint256 res) {

        uint256 liquidationDiscount = mkts[underwaterAsset].liquidationDiscount;
        uint256 onePlusLiquidationDiscount = (ONE_ETH).add(liquidationDiscount);
        res = underwaterAssetPrice.mul(onePlusLiquidationDiscount);
        res = res.mul(closeBorrowAmount_TargetUnderwaterAsset);
        res = res.div(collateralPrice);
        res = res.div(ONE_ETH);
        res = res.mul(10**mkts[collateralAsset].decimals);
        res = res.div(10**mkts[underwaterAsset].decimals);
    }

    struct LiquidateIR {
        address targetAccount;
        address assetBorrow;
        address liquidator;
        address assetCollateral;
        uint256 newBorrowIndex_UnderwaterAsset;
        uint256 newSupplyIndex_UnderwaterAsset;
        uint256 newBorrowIndex_CollateralAsset;
        uint256 newSupplyIndex_CollateralAsset;
        uint256 currentBorrowBalance_TargetUnderwaterAsset;
        uint256 updatedBorrowBalance_TargetUnderwaterAsset;
        uint256 newTotalBorrows_ProtocolUnderwaterAsset;
        uint256 startingBorrowBalance_TargetUnderwaterAsset;
        uint256 startingSupplyBalance_TargetCollateralAsset;
        uint256 startingSupplyBalance_LiquidatorCollateralAsset;
        uint256 currentSupplyBalance_TargetCollateralAsset;
        uint256 updatedSupplyBalance_TargetCollateralAsset;
        uint256 currentSupplyBalance_LiquidatorCollateralAsset;
        uint256 updatedSupplyBalance_LiquidatorCollateralAsset;
        uint256 newTotalSupply_ProtocolCollateralAsset;
        uint256 currentCash_ProtocolUnderwaterAsset;
        uint256 updatedCash_ProtocolUnderwaterAsset;

        uint256 newSupplyRateMantissa_ProtocolUnderwaterAsset;
        uint256 newBorrowRateMantissa_ProtocolUnderwaterAsset;

        uint256 discountedRepayToEvenAmount;
        uint256 discountedBorrowDenominatedCollateral;
        uint256 maxCloseableBorrowAmount_TargetUnderwaterAsset;
        uint256 closeBorrowAmount_TargetUnderwaterAsset;
        uint256 seizeSupplyAmount_TargetCollateralAsset;
        uint256 collateralPrice;
        uint256 underwaterAssetPrice;
    }

    function calcMaxLiquidateAmount(
        address targetAccount,
        address assetBorrow,
        address assetCollateral
    ) external view returns (uint256) {

        require(msg.sender != targetAccount, "can't self-liquidate");
        LiquidateIR memory tmp;

        uint256 blockDelta = now - mkts[assetBorrow].accrualBlockNumber;

        Market storage borrowMarket = mkts[assetBorrow];
        Market storage collateralMarket = mkts[assetCollateral];

        Balance storage borrowBalance_TargeUnderwaterAsset
        = accountBorrowSnapshot[assetBorrow][targetAccount];


        Balance storage supplyBalance_TargetCollateralAsset
        = accountSupplySnapshot[assetCollateral][targetAccount];

        tmp.newSupplyIndex_CollateralAsset = uint256(
            collateralMarket.irm.pert(
                int256(collateralMarket.supplyIndex),
                collateralMarket.supplyRate,
                int256(blockDelta)
            )
        );
        tmp.newBorrowIndex_UnderwaterAsset = uint256(
            borrowMarket.irm.pert(
                int256(borrowMarket.borrowIndex),
                borrowMarket.demondRate,
                int256(blockDelta)
            )
        );
        tmp.currentSupplyBalance_TargetCollateralAsset = uint256(
            collateralMarket.irm.calculateBalance(
                valid_uint(supplyBalance_TargetCollateralAsset.principal),
                int256(supplyBalance_TargetCollateralAsset.interestIndex),
                int256(tmp.newSupplyIndex_CollateralAsset)
            )
        );
        tmp.currentBorrowBalance_TargetUnderwaterAsset = uint256(
            borrowMarket.irm.calculateBalance(
                valid_uint(borrowBalance_TargeUnderwaterAsset.principal),
                int256(borrowBalance_TargeUnderwaterAsset.interestIndex),
                int256(tmp.newBorrowIndex_UnderwaterAsset)
            )
        );

        bool ok;
        (tmp.collateralPrice, ok) = fetchAssetPrice(assetCollateral);
        require(ok, "fail to get collateralPrice");

        (tmp.underwaterAssetPrice, ok) = fetchAssetPrice(assetBorrow);
        require(ok, "fail to get underwaterAssetPrice");

        tmp.discountedBorrowDenominatedCollateral = calcDiscountedBorrowDenominatedCollateral(
            assetBorrow,
            assetCollateral,
            tmp.underwaterAssetPrice,
            tmp.collateralPrice,
            tmp.currentSupplyBalance_TargetCollateralAsset
        );
        tmp.discountedRepayToEvenAmount = calcDiscountedRepayToEvenAmount(
            targetAccount,
            assetBorrow,
            tmp.underwaterAssetPrice
        );
        tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
            tmp.currentBorrowBalance_TargetUnderwaterAsset,
            tmp.discountedBorrowDenominatedCollateral
        );
        tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
            tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset,
            tmp.discountedRepayToEvenAmount
        );

        return tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset;
    }

    function liquidateBorrowPawn(
        address targetAccount,
        address assetBorrow,
        address assetCollateral,
        uint256 requestedAmountClose
    ) external payable nonReentrant {

        require(msg.sender != targetAccount, "can't self-liquidate");
        LiquidateIR memory tmp;
        tmp.targetAccount = targetAccount;
        tmp.assetBorrow = assetBorrow;
        tmp.liquidator = msg.sender;
        tmp.assetCollateral = assetCollateral;

        uint256 blockDelta = now - mkts[assetBorrow].accrualBlockNumber;

        Market storage borrowMarket = mkts[assetBorrow];
        Market storage collateralMarket = mkts[assetCollateral];

        Balance storage borrowBalance_TargeUnderwaterAsset
        = accountBorrowSnapshot[assetBorrow][targetAccount];

        Balance storage supplyBalance_TargetCollateralAsset
        = accountSupplySnapshot[assetCollateral][targetAccount];

        Balance storage supplyBalance_LiquidatorCollateralAsset
        = accountSupplySnapshot[assetCollateral][tmp.liquidator];

        bool ok;
        (tmp.collateralPrice, ok) = fetchAssetPrice(assetCollateral);
        require(ok, "fail to get collateralPrice");

        (tmp.underwaterAssetPrice, ok) = fetchAssetPrice(assetBorrow);
        require(ok, "fail to get underwaterAssetPrice");

        tmp.newBorrowIndex_UnderwaterAsset = uint256(
            borrowMarket.irm.pert(
                int256(borrowMarket.borrowIndex),
                borrowMarket.demondRate,
                int256(blockDelta)
            )
        );
        tmp.currentBorrowBalance_TargetUnderwaterAsset = uint256(
            borrowMarket.irm.calculateBalance(
                valid_uint(borrowBalance_TargeUnderwaterAsset.principal),
                int256(borrowBalance_TargeUnderwaterAsset.interestIndex),
                int256(tmp.newBorrowIndex_UnderwaterAsset)
            )
        );

        tmp.newSupplyIndex_CollateralAsset = uint256(
            collateralMarket.irm.pert(
                int256(collateralMarket.supplyIndex),
                collateralMarket.supplyRate,
                int256(blockDelta)
            )
        );
        tmp.currentSupplyBalance_TargetCollateralAsset = uint256(
            collateralMarket.irm.calculateBalance(
                valid_uint(supplyBalance_TargetCollateralAsset.principal),
                int256(supplyBalance_TargetCollateralAsset.interestIndex),
                int256(tmp.newSupplyIndex_CollateralAsset)
            )
        );

        tmp.currentSupplyBalance_LiquidatorCollateralAsset = uint256(
            collateralMarket.irm.calculateBalance(
                valid_uint(supplyBalance_LiquidatorCollateralAsset.principal),
                int256(supplyBalance_LiquidatorCollateralAsset.interestIndex),
                int256(tmp.newSupplyIndex_CollateralAsset)
            )
        );

        tmp.newTotalSupply_ProtocolCollateralAsset = collateralMarket
        .totalSupply
        .add(tmp.currentSupplyBalance_TargetCollateralAsset)
        .sub(supplyBalance_TargetCollateralAsset.principal);
        tmp.newTotalSupply_ProtocolCollateralAsset = tmp
        .newTotalSupply_ProtocolCollateralAsset
        .add(tmp.currentSupplyBalance_LiquidatorCollateralAsset)
        .sub(supplyBalance_LiquidatorCollateralAsset.principal);

        tmp.discountedBorrowDenominatedCollateral = calcDiscountedBorrowDenominatedCollateral(
            assetBorrow,
            assetCollateral,
            tmp.underwaterAssetPrice,
            tmp.collateralPrice,
            tmp.currentSupplyBalance_TargetCollateralAsset
        );
        tmp.discountedRepayToEvenAmount = calcDiscountedRepayToEvenAmount(
            targetAccount,
            assetBorrow,
            tmp.underwaterAssetPrice
        );
        tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
            min(
                tmp.currentBorrowBalance_TargetUnderwaterAsset,
                tmp.discountedBorrowDenominatedCollateral
            ),
            tmp.discountedRepayToEvenAmount
        );

        if (requestedAmountClose == uint256(-1)) {
            tmp.closeBorrowAmount_TargetUnderwaterAsset = tmp
            .maxCloseableBorrowAmount_TargetUnderwaterAsset;
        } else {
            tmp.closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
        }
        require(
            tmp.closeBorrowAmount_TargetUnderwaterAsset <=
            tmp.maxCloseableBorrowAmount_TargetUnderwaterAsset,
            "closeBorrowAmount > maxCloseableBorrowAmount err"
        );
        if (assetBorrow == address(0)) {
            require(
                msg.value >= tmp.closeBorrowAmount_TargetUnderwaterAsset,
                "Not enough ETH"
            );
        } else {
            require(
                getBalanceOf(assetBorrow, tmp.liquidator) >=
                tmp.closeBorrowAmount_TargetUnderwaterAsset,
                "insufficient balance"
            );
        }

        tmp.seizeSupplyAmount_TargetCollateralAsset = calcAmountSeize(
            assetBorrow,
            assetCollateral,
            tmp.underwaterAssetPrice,
            tmp.collateralPrice,
            tmp.closeBorrowAmount_TargetUnderwaterAsset
        );

        tmp.updatedBorrowBalance_TargetUnderwaterAsset = tmp
        .currentBorrowBalance_TargetUnderwaterAsset
        .sub(tmp.closeBorrowAmount_TargetUnderwaterAsset);
        tmp.newTotalBorrows_ProtocolUnderwaterAsset = borrowMarket
        .totalBorrows
        .add(tmp.updatedBorrowBalance_TargetUnderwaterAsset)
        .sub(borrowBalance_TargeUnderwaterAsset.principal);

        tmp.currentCash_ProtocolUnderwaterAsset = getCash(assetBorrow);
        tmp.updatedCash_ProtocolUnderwaterAsset = assetBorrow != address(0)
        ? tmp.currentCash_ProtocolUnderwaterAsset.add(
            tmp.closeBorrowAmount_TargetUnderwaterAsset
        )
        : tmp.currentCash_ProtocolUnderwaterAsset;

        tmp.newSupplyIndex_UnderwaterAsset = uint256(
            borrowMarket.irm.pert(
                int256(borrowMarket.supplyIndex),
                borrowMarket.demondRate,
                int256(blockDelta)
            )
        );
        borrowMarket.supplyRate = borrowMarket.irm.getDepositRate(
            int256(tmp.updatedCash_ProtocolUnderwaterAsset),
            int256(tmp.newTotalBorrows_ProtocolUnderwaterAsset)
        );
        borrowMarket.demondRate = borrowMarket.irm.getLoanRate(
            int256(tmp.updatedCash_ProtocolUnderwaterAsset),
            int256(tmp.newTotalBorrows_ProtocolUnderwaterAsset)
        );
        tmp.newBorrowIndex_CollateralAsset = uint256(
            collateralMarket.irm.pert(
                int256(collateralMarket.supplyIndex),
                collateralMarket.demondRate,
                int256(blockDelta)
            )
        );

        tmp.updatedSupplyBalance_TargetCollateralAsset = tmp
        .currentSupplyBalance_TargetCollateralAsset
        .sub(tmp.seizeSupplyAmount_TargetCollateralAsset);
        tmp.updatedSupplyBalance_LiquidatorCollateralAsset = tmp
        .currentSupplyBalance_LiquidatorCollateralAsset
        .add(tmp.seizeSupplyAmount_TargetCollateralAsset);

        borrowMarket.accrualBlockNumber = now;
        borrowMarket.totalBorrows = tmp.newTotalBorrows_ProtocolUnderwaterAsset;
        borrowMarket.supplyIndex = tmp.newSupplyIndex_UnderwaterAsset;
        borrowMarket.borrowIndex = tmp.newBorrowIndex_UnderwaterAsset;
        collateralMarket.accrualBlockNumber = now;
        collateralMarket.totalSupply = tmp
        .newTotalSupply_ProtocolCollateralAsset;
        collateralMarket.supplyIndex = tmp.newSupplyIndex_CollateralAsset;
        collateralMarket.borrowIndex = tmp.newBorrowIndex_CollateralAsset;
        tmp.startingBorrowBalance_TargetUnderwaterAsset = borrowBalance_TargeUnderwaterAsset
        .principal; // save for use in event
        borrowBalance_TargeUnderwaterAsset.principal = tmp
        .updatedBorrowBalance_TargetUnderwaterAsset;
        borrowBalance_TargeUnderwaterAsset.interestIndex = tmp
        .newBorrowIndex_UnderwaterAsset;

        tmp.startingSupplyBalance_TargetCollateralAsset = supplyBalance_TargetCollateralAsset
        .principal; // save for use in event
        supplyBalance_TargetCollateralAsset.principal = tmp
        .updatedSupplyBalance_TargetCollateralAsset;
        supplyBalance_TargetCollateralAsset.interestIndex = tmp
        .newSupplyIndex_CollateralAsset;

        tmp.startingSupplyBalance_LiquidatorCollateralAsset = supplyBalance_LiquidatorCollateralAsset
        .principal; // save for use in event
        supplyBalance_LiquidatorCollateralAsset.principal = tmp
        .updatedSupplyBalance_LiquidatorCollateralAsset;
        supplyBalance_LiquidatorCollateralAsset.interestIndex = tmp
        .newSupplyIndex_CollateralAsset;

        setLiquidateInfoMap(
            tmp.targetAccount,
            tmp.liquidator,
            tmp.assetCollateral,
            assetBorrow,
            tmp.seizeSupplyAmount_TargetCollateralAsset,
            tmp.closeBorrowAmount_TargetUnderwaterAsset
        );

        safeTransferFrom(
            assetBorrow,
            tmp.liquidator.makePayable(),
            address(this),
            address(this).makePayable(),
            tmp.closeBorrowAmount_TargetUnderwaterAsset,
            msg.value
        );

        emit LiquidateBorrowPawnLog(
            tmp.targetAccount,
            assetBorrow,
            tmp.updatedBorrowBalance_TargetUnderwaterAsset,
            tmp.liquidator,
            tmp.assetCollateral,
            tmp.updatedSupplyBalance_TargetCollateralAsset
        );
    }

    function safeTransferFrom(
        address token,
        address payable owner,
        address spender,
        address payable to,
        uint256 amount,
        uint256 msgValue
    ) internal {

        require(amount != 0, "invalid safeTransferFrom amount");
        if (owner != spender && token != address(0)) {
            require(
                IERC20(token).allowance(owner, spender) >= amount,
                "Insufficient allowance"
            );
        }
        if (token != address(0)) {
            require(
                IERC20(token).balanceOf(owner) >= amount,
                "Insufficient balance"
            );
        } else if (owner == spender) {
            require(owner.balance >= amount, "Insufficient eth balance");
        }

        if (owner != spender) {
            if (token != address(0)) {
                IERC20(token).safeTransferFrom(owner, to, amount);
            } else if (msgValue != 0 && msgValue > amount) {
                owner.transfer(msgValue.sub(amount));
            }
        } else {
            if (token != address(0)) {
                IERC20(token).safeTransfer(to, amount);
            } else {

                if (msgValue != 0 && msgValue > amount) {
                    to.transfer(msgValue.sub(amount));
                } else {
                    to.transfer(amount);
                }
            }
        }
    }

    function withdrawPawnEquity(address t, uint256 amount)
    external
    nonReentrant
    onlyAdmin
    {

        uint256 cash = getCash(t);
        uint256 equity = cash.add(mkts[t].totalBorrows).sub(
            mkts[t].totalSupply
        );
        require(equity >= amount, "insufficient equity amount");
        safeTransferFrom(
            t,
            address(this).makePayable(),
            address(this),
            admin.makePayable(),
            amount,
            0
        );
        emit WithdrawPawnEquityLog(t, equity, amount, admin);
    }
}