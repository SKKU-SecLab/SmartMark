
pragma solidity 0.5.14;

interface IGlobalConfig {

    function constants() external view returns (address);

    function tokenInfoRegistry() external view returns (ITokenRegistry);

    function chainLink() external view returns (address);

    function bank() external view returns (IBank);

    function savingAccount() external view returns (ISavingAccount);

    function accounts() external view returns (IAccounts);

    function maxReserveRatio() external view returns (uint256);

    function midReserveRatio() external view returns (uint256);

    function minReserveRatio() external view returns (uint256);

    function rateCurveSlope() external view returns (uint256);

    function rateCurveConstant() external view returns (uint256);

    function compoundSupplyRateWeights() external view returns (uint256);

    function compoundBorrowRateWeights() external view returns (uint256);

    function deFinerCommunityFund() external view returns (address);

    function deFinerRate() external view returns (uint256);

    function liquidationThreshold() external view returns (uint);

    function liquidationDiscountRatio() external view returns (uint);

    function owner() external view returns (address);

}

interface ITokenRegistry {

    function getTokenDecimals(address) external view returns (uint8);

    function getCToken(address) external view returns (address);

    function depositeMiningSpeeds(address) external view returns (uint256);

    function borrowMiningSpeeds(address) external view returns (uint256);

    function isSupportedOnCompound(address) external view returns (bool);

    function getTokens() external view returns (address[] memory);

    function getTokenInfoFromAddress(address _token) external view returns (uint8, uint256, uint256, uint256);

    function getTokenInfoFromIndex(uint index) external view returns (address, uint256, uint256, uint256);

    function getTokenIndex(address _token) external view returns (uint8);

    function addressFromIndex(uint index) external view returns(address);

    function isTokenExist(address _token) external view returns (bool isExist);

    function isTokenEnabled(address _token) external view returns (bool);

}

interface IAccounts {

    function deposit(address, address, uint256) external;

    function borrow(address, address, uint256) external;

    function getBorrowPrincipal(address, address) external view returns (uint256);

    function withdraw(address, address, uint256) external returns (uint256);

    function repay(address, address, uint256) external returns (uint256);

}

interface ISavingAccount {

    function toCompound(address, uint256) external;

    function fromCompound(address, uint256) external;

}

interface IBank {

    function newRateIndexCheckpoint(address) external;

    function deposit(address _to, address _token, uint256 _amount) external;

    function withdraw(address _from, address _token, uint256 _amount) external returns(uint);

    function borrow(address _from, address _token, uint256 _amount) external;

    function repay(address _to, address _token, uint256 _amount) external returns(uint);

    function getDepositAccruedRate(address _token, uint _depositRateRecordStart) external view returns (uint256);

    function getBorrowAccruedRate(address _token, uint _borrowRateRecordStart) external view returns (uint256);

    function depositeRateIndex(address _token, uint _blockNum) external view returns (uint);

    function borrowRateIndex(address _token, uint _blockNum) external view returns (uint);

    function depositeRateIndexNow(address _token) external view returns(uint);

    function borrowRateIndexNow(address _token) external view returns(uint);

    function updateMining(address _token) external;

    function updateDepositFINIndex(address _token) external;

    function updateBorrowFINIndex(address _token) external;

    function depositFINRateIndex(address, uint) external view returns (uint);

    function borrowFINRateIndex(address, uint) external view returns (uint);

}

interface ICToken {

    function supplyRatePerBlock() external view returns (uint);

    function borrowRatePerBlock() external view returns (uint);

    function mint(uint mintAmount) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function redeem(uint redeemAmount) external returns (uint);

    function exchangeRateStore() external view returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint);

}

interface ICETH{

    function mint() external payable;

}

interface IController {

    function fastForward(uint blocks) external returns (uint);

    function getBlockNumber() external view returns (uint);

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


contract Constant {

    enum ActionType { DepositAction, WithdrawAction, BorrowAction, RepayAction }
    address public constant ETH_ADDR = 0x000000000000000000000000000000000000000E;
    uint256 public constant INT_UNIT = 10 ** uint256(18);
    uint256 public constant ACCURACY = 10 ** 18;
    uint256 public constant BLOCKS_PER_YEAR = 2102400;
}


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


contract Bank is Constant, Initializable{

    using SafeMath for uint256;

    mapping(address => uint256) public totalLoans;     // amount of lended tokens
    mapping(address => uint256) public totalReserve;   // amount of tokens in reservation
    mapping(address => uint256) public totalCompound;  // amount of tokens in compound
    mapping(address => mapping(uint => uint)) public depositeRateIndex; // the index curve of deposit rate
    mapping(address => mapping(uint => uint)) public borrowRateIndex;   // the index curve of borrow rate
    mapping(address => uint) public lastCheckpoint;            // last checkpoint on the index curve
    mapping(address => uint) public lastCTokenExchangeRate;    // last compound cToken exchange rate
    mapping(address => ThirdPartyPool) compoundPool;    // the compound pool

    IGlobalConfig globalConfig;            // global configuration contract address

    mapping(address => mapping(uint => uint)) public depositFINRateIndex;
    mapping(address => mapping(uint => uint)) public borrowFINRateIndex;
    mapping(address => uint) public lastDepositFINRateCheckpoint;
    mapping(address => uint) public lastBorrowFINRateCheckpoint;

    modifier onlyAuthorized() {

        require(msg.sender == address(globalConfig.savingAccount()) || msg.sender == address(globalConfig.accounts()),
            "Only authorized to call from DeFiner internal contracts.");
        _;
    }

    struct ThirdPartyPool {
        bool supported;             // if the token is supported by the third party platforms such as Compound
        uint capitalRatio;          // the ratio of the capital in third party to the total asset
        uint depositRatePerBlock;   // the deposit rate of the token in third party
        uint borrowRatePerBlock;    // the borrow rate of the token in third party
    }

    event UpdateIndex(address indexed token, uint256 depositeRateIndex, uint256 borrowRateIndex);
    event UpdateDepositFINIndex(address indexed _token, uint256 depositFINRateIndex);
    event UpdateBorrowFINIndex(address indexed _token, uint256 borrowFINRateIndex);

    function initialize(
        IGlobalConfig _globalConfig
    ) public initializer {

        globalConfig = _globalConfig;
    }

    function getTotalDepositStore(address _token) public view returns(uint) {

        address cToken = globalConfig.tokenInfoRegistry().getCToken(_token);
        return totalCompound[cToken].add(totalLoans[_token]).add(totalReserve[_token]); // return totalAmount = C + U + R
    }

    function updateTotalCompound(address _token) internal {

        address cToken = globalConfig.tokenInfoRegistry().getCToken(_token);
        if(cToken != address(0)) {
            totalCompound[cToken] = ICToken(cToken).balanceOfUnderlying(address(globalConfig.savingAccount()));
        }
    }

    function updateTotalReserve(address _token, uint _amount, ActionType _action) internal returns(uint256 compoundAmount){

        address cToken = globalConfig.tokenInfoRegistry().getCToken(_token);
        uint totalAmount = getTotalDepositStore(_token);
        if (_action == ActionType.DepositAction || _action == ActionType.RepayAction) {
            if (_action == ActionType.DepositAction)
                totalAmount = totalAmount.add(_amount);
            else
                totalLoans[_token] = totalLoans[_token].sub(_amount);

            uint totalReserveBeforeAdjust = totalReserve[_token].add(_amount);

            if (cToken != address(0) &&
            totalReserveBeforeAdjust > totalAmount.mul(globalConfig.maxReserveRatio()).div(100)) {
                uint toCompoundAmount = totalReserveBeforeAdjust.sub(totalAmount.mul(globalConfig.midReserveRatio()).div(100));
                compoundAmount = toCompoundAmount;
                totalCompound[cToken] = totalCompound[cToken].add(toCompoundAmount);
                totalReserve[_token] = totalReserve[_token].add(_amount).sub(toCompoundAmount);
            }
            else {
                totalReserve[_token] = totalReserve[_token].add(_amount);
            }
        } else {
            if(_action == ActionType.WithdrawAction) {
                if(totalLoans[_token] != 0)
                    require(getPoolAmount(_token) >= _amount, "Lack of liquidity when withdraw.");
                else if (getPoolAmount(_token) < _amount)
                    totalReserve[_token] = _amount.sub(totalCompound[cToken]);
                totalAmount = getTotalDepositStore(_token);
            }
            else
                require(getPoolAmount(_token) >= _amount, "Lack of liquidity when borrow.");

            if (_action == ActionType.WithdrawAction)
                totalAmount = totalAmount.sub(_amount);
            else
                totalLoans[_token] = totalLoans[_token].add(_amount);

            uint totalReserveBeforeAdjust = totalReserve[_token] > _amount ? totalReserve[_token].sub(_amount) : 0;

            if(cToken != address(0) &&
            (totalAmount == 0 || totalReserveBeforeAdjust < totalAmount.mul(globalConfig.minReserveRatio()).div(100))) {

                uint totalAvailable = totalReserve[_token].add(totalCompound[cToken]).sub(_amount);
                if (totalAvailable < totalAmount.mul(globalConfig.midReserveRatio()).div(100)){
                    compoundAmount = totalCompound[cToken];
                    totalCompound[cToken] = 0;
                    totalReserve[_token] = totalAvailable;
                } else {
                    uint totalInCompound = totalAvailable.sub(totalAmount.mul(globalConfig.midReserveRatio()).div(100));
                    compoundAmount = totalCompound[cToken].sub(totalInCompound);
                    totalCompound[cToken] = totalInCompound;
                    totalReserve[_token] = totalAvailable.sub(totalInCompound);
                }
            }
            else {
                totalReserve[_token] = totalReserve[_token].sub(_amount);
            }
        }
        return compoundAmount;
    }

     function update(address _token, uint _amount, ActionType _action) public onlyAuthorized returns(uint256 compoundAmount) {

        updateTotalCompound(_token);
        compoundAmount = updateTotalReserve(_token, _amount, _action);
        return compoundAmount;
    }

    function updateDepositFINIndex(address _token) public onlyAuthorized{

        uint currentBlock = getBlockNumber();
        uint deltaBlock;
        deltaBlock = lastDepositFINRateCheckpoint[_token] == 0 ? 0 : currentBlock.sub(lastDepositFINRateCheckpoint[_token]);
        depositFINRateIndex[_token][currentBlock] = depositFINRateIndex[_token][lastDepositFINRateCheckpoint[_token]].add(
            getTotalDepositStore(_token) == 0 ? 0 : depositeRateIndex[_token][lastCheckpoint[_token]]
                .mul(deltaBlock)
                .mul(globalConfig.tokenInfoRegistry().depositeMiningSpeeds(_token))
                .div(getTotalDepositStore(_token)));
        lastDepositFINRateCheckpoint[_token] = currentBlock;

        emit UpdateDepositFINIndex(_token, depositFINRateIndex[_token][currentBlock]);
    }

    function updateBorrowFINIndex(address _token) public onlyAuthorized{

        uint currentBlock = getBlockNumber();
        uint deltaBlock;
        deltaBlock = lastBorrowFINRateCheckpoint[_token] == 0 ? 0 : currentBlock.sub(lastBorrowFINRateCheckpoint[_token]);
        borrowFINRateIndex[_token][currentBlock] = borrowFINRateIndex[_token][lastBorrowFINRateCheckpoint[_token]].add(
            totalLoans[_token] == 0 ? 0 : borrowRateIndex[_token][lastCheckpoint[_token]]
                    .mul(deltaBlock)
                    .mul(globalConfig.tokenInfoRegistry().borrowMiningSpeeds(_token))
                    .div(totalLoans[_token]));
        lastBorrowFINRateCheckpoint[_token] = currentBlock;

        emit UpdateBorrowFINIndex(_token, borrowFINRateIndex[_token][currentBlock]);
    }

    function updateMining(address _token) public onlyAuthorized{

        newRateIndexCheckpoint(_token);
        updateTotalCompound(_token);
    }

    function getBorrowRatePerBlock(address _token) public view returns(uint) {

        uint256 capitalUtilizationRatio = getCapitalUtilizationRatio(_token);
        uint256 rateCurveConstant = globalConfig.rateCurveConstant();
        uint256 compoundSupply = compoundPool[_token].depositRatePerBlock.mul(globalConfig.compoundSupplyRateWeights());
        uint256 compoundBorrow = compoundPool[_token].borrowRatePerBlock.mul(globalConfig.compoundBorrowRateWeights());
        uint256 nonUtilizedCapRatio = INT_UNIT.sub(capitalUtilizationRatio);

        bool isSupportedOnCompound = globalConfig.tokenInfoRegistry().isSupportedOnCompound(_token);
        if(isSupportedOnCompound) {
            uint256 compoundSupplyPlusBorrow = compoundSupply.add(compoundBorrow).div(10);
            uint256 rateConstant;
            if(capitalUtilizationRatio > ((10**18) - (10**15))) { // > 0.999
                rateConstant = rateCurveConstant.mul(1000).div(BLOCKS_PER_YEAR);
                return compoundSupplyPlusBorrow.add(rateConstant);
            } else {
                rateConstant = rateCurveConstant.mul(10**18).div(nonUtilizedCapRatio).div(BLOCKS_PER_YEAR);
                return compoundSupplyPlusBorrow.add(rateConstant);
            }
        } else {
            if(capitalUtilizationRatio > ((10**18) - (10**15))) { // > 0.999
                return rateCurveConstant.mul(1000).div(BLOCKS_PER_YEAR);
            } else {
                return rateCurveConstant.mul(10**18).div(nonUtilizedCapRatio).div(BLOCKS_PER_YEAR);
            }
        }
    }

    function getDepositRatePerBlock(address _token) public view returns(uint) {

        uint256 borrowRatePerBlock = getBorrowRatePerBlock(_token);
        uint256 capitalUtilRatio = getCapitalUtilizationRatio(_token);
        if(!globalConfig.tokenInfoRegistry().isSupportedOnCompound(_token))
            return borrowRatePerBlock.mul(capitalUtilRatio).div(INT_UNIT);

        return borrowRatePerBlock.mul(capitalUtilRatio).add(compoundPool[_token].depositRatePerBlock
            .mul(compoundPool[_token].capitalRatio)).div(INT_UNIT);
    }

    function getCapitalUtilizationRatio(address _token) public view returns(uint) {

        uint256 totalDepositsNow = getTotalDepositStore(_token);
        if(totalDepositsNow == 0) {
            return 0;
        } else {
            return totalLoans[_token].mul(INT_UNIT).div(totalDepositsNow);
        }
    }

    function getCapitalCompoundRatio(address _token) public view returns(uint) {

        address cToken = globalConfig.tokenInfoRegistry().getCToken(_token);
        if(totalCompound[cToken] == 0 ) {
            return 0;
        } else {
            return uint(totalCompound[cToken].mul(INT_UNIT).div(getTotalDepositStore(_token)));
        }
    }

    function getDepositAccruedRate(address _token, uint _depositRateRecordStart) external view returns (uint256) {

        uint256 depositRate = depositeRateIndex[_token][_depositRateRecordStart];
        require(depositRate != 0, "_depositRateRecordStart is not a check point on index curve.");
        return depositeRateIndexNow(_token).mul(INT_UNIT).div(depositRate);
    }

    function getBorrowAccruedRate(address _token, uint _borrowRateRecordStart) external view returns (uint256) {

        uint256 borrowRate = borrowRateIndex[_token][_borrowRateRecordStart];
        require(borrowRate != 0, "_borrowRateRecordStart is not a check point on index curve.");
        return borrowRateIndexNow(_token).mul(INT_UNIT).div(borrowRate);
    }

    function newRateIndexCheckpoint(address _token) public onlyAuthorized {


        uint blockNumber = getBlockNumber();
        if (blockNumber == lastCheckpoint[_token])
            return;

        uint256 UNIT = INT_UNIT;
        address cToken = globalConfig.tokenInfoRegistry().getCToken(_token);

        uint256 previousCheckpoint = lastCheckpoint[_token];
        if (lastCheckpoint[_token] == 0) {
            if(cToken == address(0)) {
                compoundPool[_token].supported = false;
                borrowRateIndex[_token][blockNumber] = UNIT;
                depositeRateIndex[_token][blockNumber] = UNIT;
                lastCheckpoint[_token] = blockNumber;
            }
            else {
                compoundPool[_token].supported = true;
                uint cTokenExchangeRate = ICToken(cToken).exchangeRateCurrent();
                compoundPool[_token].capitalRatio = getCapitalCompoundRatio(_token);
                compoundPool[_token].borrowRatePerBlock = ICToken(cToken).borrowRatePerBlock();  // initial value
                compoundPool[_token].depositRatePerBlock = ICToken(cToken).supplyRatePerBlock(); // initial value
                borrowRateIndex[_token][blockNumber] = UNIT;
                depositeRateIndex[_token][blockNumber] = UNIT;
                lastCheckpoint[_token] = blockNumber;
                lastCTokenExchangeRate[cToken] = cTokenExchangeRate;
            }

        } else {
            if(cToken == address(0)) {
                compoundPool[_token].supported = false;
                borrowRateIndex[_token][blockNumber] = borrowRateIndexNow(_token);
                depositeRateIndex[_token][blockNumber] = depositeRateIndexNow(_token);
                lastCheckpoint[_token] = blockNumber;
            } else {
                compoundPool[_token].supported = true;
                uint cTokenExchangeRate = ICToken(cToken).exchangeRateCurrent();
                compoundPool[_token].capitalRatio = getCapitalCompoundRatio(_token);
                compoundPool[_token].borrowRatePerBlock = ICToken(cToken).borrowRatePerBlock();
                compoundPool[_token].depositRatePerBlock = cTokenExchangeRate.mul(UNIT).div(lastCTokenExchangeRate[cToken])
                    .sub(UNIT).div(blockNumber.sub(lastCheckpoint[_token]));
                borrowRateIndex[_token][blockNumber] = borrowRateIndexNow(_token);
                depositeRateIndex[_token][blockNumber] = depositeRateIndexNow(_token);
                lastCheckpoint[_token] = blockNumber;
                lastCTokenExchangeRate[cToken] = cTokenExchangeRate;
            }
        }

        if(borrowRateIndex[_token][blockNumber] != UNIT) {
            totalLoans[_token] = totalLoans[_token].mul(borrowRateIndex[_token][blockNumber])
                .div(borrowRateIndex[_token][previousCheckpoint]);
        }

        emit UpdateIndex(_token, depositeRateIndex[_token][getBlockNumber()], borrowRateIndex[_token][getBlockNumber()]);
    }

    function depositeRateIndexNow(address _token) public view returns(uint) {

        uint256 lcp = lastCheckpoint[_token];
        if(lcp == 0)
            return INT_UNIT;

        uint256 lastDepositeRateIndex = depositeRateIndex[_token][lcp];
        uint256 depositRatePerBlock = getDepositRatePerBlock(_token);
        return lastDepositeRateIndex.mul(getBlockNumber().sub(lcp).mul(depositRatePerBlock).add(INT_UNIT)).div(INT_UNIT);
    }

    function borrowRateIndexNow(address _token) public view returns(uint) {

        uint256 lcp = lastCheckpoint[_token];
        if(lcp == 0)
            return INT_UNIT;
        uint256 lastBorrowRateIndex = borrowRateIndex[_token][lcp];
        uint256 borrowRatePerBlock = getBorrowRatePerBlock(_token);
        return lastBorrowRateIndex.mul(getBlockNumber().sub(lcp).mul(borrowRatePerBlock).add(INT_UNIT)).div(INT_UNIT);
    }

    function getTokenState(address _token) public view returns (uint256 deposits, uint256 loans, uint256 reserveBalance, uint256 remainingAssets){

        return (
        getTotalDepositStore(_token),
        totalLoans[_token],
        totalReserve[_token],
        totalReserve[_token].add(totalCompound[globalConfig.tokenInfoRegistry().getCToken(_token)])
        );
    }

    function getPoolAmount(address _token) public view returns(uint) {

        return totalReserve[_token].add(totalCompound[globalConfig.tokenInfoRegistry().getCToken(_token)]);
    }

    function deposit(address _to, address _token, uint256 _amount) external onlyAuthorized {


        require(_amount != 0, "Amount is zero");

        newRateIndexCheckpoint(_token);
        updateDepositFINIndex(_token);

        globalConfig.accounts().deposit(_to, _token, _amount);

        uint compoundAmount = update(_token, _amount, ActionType.DepositAction);

        if(compoundAmount > 0) {
            globalConfig.savingAccount().toCompound(_token, compoundAmount);
        }
    }

    function borrow(address _from, address _token, uint256 _amount) external onlyAuthorized {


        newRateIndexCheckpoint(_token);
        updateBorrowFINIndex(_token);

        globalConfig.accounts().borrow(_from, _token, _amount);

        uint compoundAmount = update(_token, _amount, ActionType.BorrowAction);

        if(compoundAmount > 0) {
            globalConfig.savingAccount().fromCompound(_token, compoundAmount);
        }
    }

    function repay(address _to, address _token, uint256 _amount) external onlyAuthorized returns(uint) {


        newRateIndexCheckpoint(_token);
        updateBorrowFINIndex(_token);

        require(globalConfig.accounts().getBorrowPrincipal(_to, _token) > 0,
            "Token BorrowPrincipal must be greater than 0. To deposit balance, please use deposit button."
        );

        uint256 remain = globalConfig.accounts().repay(_to, _token, _amount);

        uint compoundAmount = update(_token, _amount.sub(remain), ActionType.RepayAction);
        if(compoundAmount > 0) {
           globalConfig.savingAccount().toCompound(_token, compoundAmount);
        }

        return _amount.sub(remain);
    }

    function withdraw(address _from, address _token, uint256 _amount) external onlyAuthorized returns(uint) {


        require(_amount != 0, "Amount is zero");

        newRateIndexCheckpoint(_token);
        updateDepositFINIndex(_token);

        uint amount = globalConfig.accounts().withdraw(_from, _token, _amount);

        uint compoundAmount = update(_token, amount, ActionType.WithdrawAction);

        if(compoundAmount > 0) {
            globalConfig.savingAccount().fromCompound(_token, compoundAmount);
        }

        return amount;
    }

    function getBlockNumber() private view returns (uint) {

        return block.number;
    }

    function version() public pure returns(string memory) {

        return "v1.2.0";
    }

}