
pragma solidity ^0.8.2;

interface IP2Controller {


    function mintAllowed(address xToken, address minter, uint256 mintAmount) external;


    function mintVerify(address xToken, address account) external;


    function redeemAllowed(address xToken, address redeemer, uint256 redeemTokens, uint256 redeemAmount) external;


    function redeemVerify(address xToken, address redeemer) external;

    
    function borrowAllowed(address xToken, uint256 orderId, address borrower, uint256 borrowAmount) external;


    function borrowVerify(uint256 orderId, address xToken, address borrower) external;


    function repayBorrowAllowed(address xToken, uint256 orderId, address borrower, address payer, uint256 repayAmount) external;


    function repayBorrowVerify(address xToken, uint256 orderId, address borrower, address payer, uint256 repayAmount) external;


    function repayBorrowAndClaimVerify(address xToken, uint256 orderId) external;


    function liquidateBorrowAllowed(address xToken, uint256 orderId, address borrower, address liquidator) external;


    function liquidateBorrowVerify(address xToken, uint256 orderId, address borrower, address liquidator, uint256 repayAmount)external;

    
    function transferAllowed(address xToken, address src, address dst, uint256 transferTokens) external;


    function transferVerify(address xToken, address src, address dst) external;


    function getOrderBorrowBalanceCurrent(uint256 orderId) external returns(uint256);



    function addPool(address xToken, uint256 _borrowCap, uint256 _supplyCap) external;


    function addCollateral(address _collection, uint256 _collateralFactor, uint256 _liquidateFactor, address[] calldata _pools) external;


    function setPriceOracle(address _oracle) external;


    function setXNFT(address _xNFT) external;

    
}// MIT

pragma solidity ^0.8.2;

interface IOracle {

    function getPrice(address collection, address denotedToken) external view returns (uint256, bool);

}// MIT

pragma solidity ^0.8.2;

interface IXNFT {


    function pledge(address collection, uint256 tokenId, uint256 nftType) external;

    function pledge721(address _collection, uint256 _tokenId) external;

    function pledge1155(address _collection, uint256 _tokenId) external;

    function getOrderDetail(uint256 orderId) external view returns(address collection, uint256 tokenId, address pledger);

    function isOrderLiquidated(uint256 orderId) external view returns(bool);

    function withdrawNFT(uint256 orderId) external;



    function notifyOrderLiquidated(address xToken, uint256 orderId, address liquidator, uint256 liquidatedPrice) external;

    function notifyRepayBorrow(uint256 orderId) external;


}// MIT

pragma solidity ^0.8.2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    function decimals() external view returns (uint8);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// MIT

pragma solidity ^0.8.2;

interface IInterestRateModel {


    function blocksPerYear() external view returns (uint256); 


    function isInterestRateModel() external returns(bool);


    function getBorrowRate(
        uint256 cash, 
        uint256 borrows, 
        uint256 reserves) external view returns (uint256);


    function getSupplyRate(
        uint256 cash, 
        uint256 borrows, 
        uint256 reserves, 
        uint256 reserveFactor) external view returns (uint256);

}// MIT

pragma solidity ^0.8.2;

interface IXToken is IERC20 {


    function balanceOfUnderlying(address owner) external returns (uint256);


    function mint(uint256 amount) external payable;

    function redeem(uint256 redeemTokens) external;

    function redeemUnderlying(uint256 redeemAmounts) external;


    function borrow(uint256 orderId, address payable borrower, uint256 borrowAmount) external;

    function repayBorrow(uint256 orderId, address borrower, uint256 repayAmount) external payable;

    function liquidateBorrow(uint256 orderId, address borrower) external payable;


    function orderLiquidated(uint256 orderId) external view returns(bool, address, uint256); 


    function accrueInterest() external;


    function borrowBalanceCurrent(uint256 orderId) external returns (uint256);

    function borrowBalanceStored(uint256 orderId) external view returns (uint256);


    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);


    function underlying() external view returns(address);

    function totalBorrows() external view returns(uint256);

    function totalCash() external view returns (uint256);

    function totalReserves() external view returns (uint256);


    function setPendingAdmin(address payable newPendingAdmin) external;

    function acceptAdmin() external;

    function setReserveFactor(uint256 newReserveFactor) external;

    function reduceReserves(uint256 reduceAmount) external;

    function setInterestRateModel(IInterestRateModel newInterestRateModel) external;

    function setTransferEthGasCost(uint256 _transferEthGasCost) external;


    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
    event Borrow(uint256 orderId, address borrower, uint256 borrowAmount, uint256 orderBorrows, uint256 totalBorrows);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    
}pragma solidity ^0.8.2;

interface ILiquidityMining {


    function updateBorrow(address xToken, address collection, uint256 amount, address account, uint256 orderId, bool isDeposit) external; 


    function updateSupply(address xToken, uint256 amount, address account, bool isDeposit) external;

}// MIT

pragma solidity ^0.8.2;


contract P2ControllerStorage{


    address public admin;
    address public pendingAdmin;

    bool internal _notEntered;

    struct PoolState{
        bool isListed;
        uint256 borrowCap;
        uint256 supplyCap;
    }
    mapping(address => PoolState) public poolStates;

    struct CollateralState{
        bool isListed;
        uint256 collateralFactor;
        uint256 liquidateFactor;
        bool isSupportAllPools;
        mapping(address => bool) supportPools;
    }
    mapping(address => CollateralState) public collateralStates;

    mapping(uint256 => address) public orderDebtStates;

    IXNFT public xNFT;
    IOracle public oracle;
    ILiquidityMining public liquidityMining;

    uint256 internal constant COLLATERAL_FACTOR_MAX = 1e18;
    uint256 internal constant LIQUIDATE_FACTOR_MAX = 1e18;

    mapping(address => mapping(uint256 => bool)) public xTokenPausedMap;
}// MIT

pragma solidity ^0.8.2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a <= b ? a : b;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return b - a;
        }
        return a - b;
    }
}// MIT

pragma solidity ^0.8.2;


contract Exponential {

    uint256 constant expScale = 1e18;
    uint256 constant halfExpScale = expScale / 2;

    using SafeMath for uint256;

    function getExp(uint256 num, uint256 denom)
        public
        pure
        returns (uint256 rational)
    {

        rational = num.mul(expScale).div(denom);
    }

    function getDiv(uint256 num, uint256 denom)
        public
        pure
        returns (uint256 rational)
    {

        rational = num.mul(expScale).div(denom);
    }

    function addExp(uint256 a, uint256 b) public pure returns (uint256 result) {

        result = a.add(b);
    }

    function subExp(uint256 a, uint256 b) public pure returns (uint256 result) {

        result = a.sub(b);
    }

    function mulExp(uint256 a, uint256 b) public pure returns (uint256) {

        uint256 doubleScaledProduct = a.mul(b);

        uint256 doubleScaledProductWithHalfScale = halfExpScale.add(
            doubleScaledProduct
        );

        return doubleScaledProductWithHalfScale.div(expScale);
    }

    function divExp(uint256 a, uint256 b) public pure returns (uint256) {

        return getDiv(a, b);
    }

    function mulExp3(
        uint256 a,
        uint256 b,
        uint256 c
    ) external pure returns (uint256) {

        return mulExp(mulExp(a, b), c);
    }

    function mulScalar(uint256 a, uint256 scalar)
        public
        pure
        returns (uint256 scaled)
    {

        scaled = a.mul(scalar);
    }

    function mulScalarTruncate(uint256 a, uint256 scalar)
        public
        pure
        returns (uint256)
    {

        uint256 product = mulScalar(a, scalar);
        return truncate(product);
    }

    function mulScalarTruncateAddUInt(
        uint256 a,
        uint256 scalar,
        uint256 addend
    ) external pure returns (uint256) {

        uint256 product = mulScalar(a, scalar);
        return truncate(product).add(addend);
    }

    function divScalarByExpTruncate(uint256 scalar, uint256 divisor)
        public
        pure
        returns (uint256)
    {

        uint256 fraction = divScalarByExp(scalar, divisor);
        return truncate(fraction);
    }

    function divScalarByExp(uint256 scalar, uint256 divisor)
        public
        pure
        returns (uint256)
    {

        uint256 numerator = expScale.mul(scalar);
        return getExp(numerator, divisor);
    }

    function divScalar(uint256 a, uint256 scalar)
        external
        pure
        returns (uint256)
    {

        return a.div(scalar);
    }

    function truncate(uint256 exp) public pure returns (uint256) {

        return exp.div(expScale);
    }
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.2;


contract P2Controller is P2ControllerStorage, Exponential,  Initializable{


    using SafeMath for uint256;

    function initialize(ILiquidityMining _liquidityMining) external initializer {

        admin = msg.sender;
        liquidityMining = _liquidityMining;
    }

    function mintAllowed(address xToken, address minter, uint256 mintAmount) external view whenNotPaused(xToken, 1){

        require(poolStates[xToken].isListed, "token not listed");

        uint256 supplyCap = poolStates[xToken].supplyCap;

        if (supplyCap != 0) {
            uint256 _totalSupply = IXToken(xToken).totalSupply();
            uint256 _exchangeRate = IXToken(xToken).exchangeRateStored();
            
            uint256 totalUnderlyingSupply = mulScalarTruncate(_exchangeRate, _totalSupply);
            uint nextTotalUnderlyingSupply = totalUnderlyingSupply.add(mintAmount);
            require(nextTotalUnderlyingSupply < supplyCap, "market supply cap reached");
        }
    }

    function mintVerify(address xToken, address account) external whenNotPaused(xToken, 1){

        updateSupplyVerify(xToken, account, true);
    }

    function redeemAllowed(address xToken, address redeemer, uint256 redeemTokens, uint256 redeemAmount) external view whenNotPaused(xToken, 2){

        require(poolStates[xToken].isListed, "token not listed");
    }

    function redeemVerify(address xToken, address redeemer) external whenNotPaused(xToken, 2){

        updateSupplyVerify(xToken, redeemer, false);
    } 

    function orderAllowed(uint256 orderId, address borrower) internal view returns(address){

        (address _collection , , address _pledger) = xNFT.getOrderDetail(orderId);

        require((_collection != address(0) && _pledger != address(0)), "order not exist");
        require(_pledger == borrower, "borrower don't hold the order");

        bool isLiquidated = xNFT.isOrderLiquidated(orderId);
        require(!isLiquidated, "order has been liquidated");
        return _collection;
    }

    function borrowAllowed(address xToken, uint256 orderId, address borrower, uint256 borrowAmount) external whenNotPaused(xToken, 3){

        require(poolStates[xToken].isListed, "token not listed");

        orderAllowed(orderId, borrower);

        (address _collection , , ) = xNFT.getOrderDetail(orderId);

        CollateralState storage _collateralState = collateralStates[_collection];
        require(_collateralState.isListed, "collection not exist");
        require(_collateralState.supportPools[xToken] || _collateralState.isSupportAllPools, "collection don't support this pool");

        address _lastXToken = orderDebtStates[orderId];
        require(_lastXToken == address(0) || _lastXToken == xToken, "only support borrowing of one xToken");

        (uint256 _price, bool valid) = oracle.getPrice(_collection, IXToken(xToken).underlying());
        require(_price > 0 && valid, "price is not valid");

        if (poolStates[xToken].borrowCap != 0) {
            require(IXToken(xToken).totalBorrows().add(borrowAmount) < poolStates[xToken].borrowCap, "pool borrow cap reached");
        }

        uint256 _maxBorrow = mulScalarTruncate(_price, _collateralState.collateralFactor);
        uint256 _mayBorrowed = borrowAmount;
        if (_lastXToken != address(0)){
            _mayBorrowed = IXToken(_lastXToken).borrowBalanceStored(orderId).add(borrowAmount);  
        }
        require(_mayBorrowed <= _maxBorrow, "borrow amount exceed");

        if (_lastXToken == address(0)){
            orderDebtStates[orderId] = xToken;
        }
    }

    function borrowVerify(uint256 orderId, address xToken, address borrower) external whenNotPaused(xToken, 3){

        require(orderDebtStates[orderId] == xToken , "collateral debt invalid");
        uint256 _borrowBalance = IXToken(xToken).borrowBalanceCurrent(orderId);
        updateBorrowVerify(orderId, xToken, borrower, _borrowBalance, true);
    }

    function repayBorrowAllowed(address xToken, uint256 orderId, address borrower, address payer, uint256 repayAmount) external view whenNotPaused(xToken, 4){

        require(poolStates[xToken].isListed, "token not listed");

        address _collection = orderAllowed(orderId, borrower);

        require(orderDebtStates[orderId] == xToken , "collateral debt invalid");
    }

    function repayBorrowVerify(address xToken, uint256 orderId, address borrower, address payer, uint256 repayAmount) external whenNotPaused(xToken, 4){

        require(orderDebtStates[orderId] == xToken , "collateral debt invalid");
        uint256 _borrowBalance = IXToken(xToken).borrowBalanceCurrent(orderId);

        updateBorrowVerify(orderId, xToken, borrower, _borrowBalance, false);

        if (_borrowBalance == 0) {
            delete orderDebtStates[orderId];
        }
    }

    function repayBorrowAndClaimVerify(address xToken, uint256 orderId) external whenNotPaused(xToken, 4){

        require(orderDebtStates[orderId] == address(0), "address invalid");
        xNFT.notifyRepayBorrow(orderId);
    }

    function liquidateBorrowAllowed(address xToken, uint256 orderId, address borrower, address liquidator) external view whenNotPaused(xToken, 5){

        require(poolStates[xToken].isListed, "token not listed");

        orderAllowed(orderId, borrower);

        (address _collection , , ) = xNFT.getOrderDetail(orderId);

        require(orderDebtStates[orderId] == xToken , "collateral debt invalid");

        (uint256 _price, bool valid) = oracle.getPrice(_collection, IXToken(xToken).underlying());
        require(_price > 0 && valid, "price is not valid");

        uint256 _borrowBalance = IXToken(xToken).borrowBalanceStored(orderId);
        uint256 _liquidateBalance = mulScalarTruncate(_price, collateralStates[_collection].liquidateFactor);

        require(_borrowBalance > _liquidateBalance, "order don't exceed borrow balance");
    } 

    function liquidateBorrowVerify(address xToken, uint256 orderId, address borrower, address liquidator, uint256 repayAmount)external whenNotPaused(xToken, 5){

        orderAllowed(orderId, borrower);

        (bool _valid, address _liquidator, uint256 _liquidatedPrice) = IXToken(xToken).orderLiquidated(orderId);

        if (_valid && _liquidator != address(0)){
            xNFT.notifyOrderLiquidated(xToken, orderId, _liquidator, _liquidatedPrice);
        }
    }

    function transferAllowed(address xToken, address src, address dst, uint256 transferTokens) external view{

        require(poolStates[xToken].isListed, "token not listed");
    }

    function transferVerify(address xToken, address src, address dst) external{

        updateSupplyVerify(xToken, src, false);
        updateSupplyVerify(xToken, dst, true);
    }

    function getOrderBorrowBalanceCurrent(uint256 orderId) external returns(uint256){

        address _xToken = orderDebtStates[orderId];
        if (_xToken == address(0)){
            return 0;
        }
        uint256 _borrowBalance = IXToken(_xToken).borrowBalanceCurrent(orderId);
        return _borrowBalance;
    }

    function getCollateralStateSupportPools(address collection, address xToken) external view returns(bool){

        return collateralStates[collection].supportPools[xToken];
    }

    function updateSupplyVerify(address xToken, address account, bool isDeposit) internal{

        uint256 balance = IXToken(xToken).balanceOf(account);
        if(address(liquidityMining) != address(0)){
            liquidityMining.updateSupply(xToken, balance, account, isDeposit);
        }
    }

    function updateBorrowVerify(uint256 orderId, address xToken, address account, uint256 borrowBalance, bool isDeposit) internal{

        address collection = orderAllowed(orderId, account);
        if(address(liquidityMining) != address(0)){
            liquidityMining.updateBorrow(xToken, collection, borrowBalance, account, orderId, isDeposit);
        }
    }


    function addPool(address xToken, uint256 _borrowCap, uint256 _supplyCap) external onlyAdmin{

        require(!poolStates[xToken].isListed, "pool has added");
        poolStates[xToken] = PoolState(
            true,
            _borrowCap,
            _supplyCap
        );
    }

    function addCollateral(address _collection, uint256 _collateralFactor, uint256 _liquidateFactor, address[] calldata _pools) external onlyAdmin{

        require(!collateralStates[_collection].isListed, "collection has added");
        require(_collateralFactor <= COLLATERAL_FACTOR_MAX, "_collateralFactor is greater than COLLATERAL_FACTOR_MAX");
        require(_liquidateFactor <= LIQUIDATE_FACTOR_MAX, " _liquidateFactor is greater than LIQUIDATE_FACTOR_MAX");
        
        collateralStates[_collection].isListed = true;
        collateralStates[_collection].collateralFactor = _collateralFactor;
        collateralStates[_collection].liquidateFactor = _liquidateFactor;

        if (_pools.length == 0){
            collateralStates[_collection].isSupportAllPools = true;
        }else{
            collateralStates[_collection].isSupportAllPools = false;

            for (uint i = 0; i < _pools.length; i++){
                collateralStates[_collection].supportPools[_pools[i]] = true;
            }
        }
    }

    function setCollateralState(address _collection, uint256 _collateralFactor, uint256 _liquidateFactor) external onlyAdmin {

        require(collateralStates[_collection].isListed, "collection has not added");
        require(_collateralFactor <= COLLATERAL_FACTOR_MAX, "_collateralFactor is greater than COLLATERAL_FACTOR_MAX");
        require(_liquidateFactor <= LIQUIDATE_FACTOR_MAX, " _liquidateFactor is greater than LIQUIDATE_FACTOR_MAX");
        collateralStates[_collection].collateralFactor = _collateralFactor;
        collateralStates[_collection].liquidateFactor = _liquidateFactor;
    }

    function setCollateralSupportPools(address _collection, address[] calldata _pools) external onlyAdmin{

        require(collateralStates[_collection].isListed, "collection has not added");
        
        if (_pools.length == 0){
            collateralStates[_collection].isSupportAllPools = true;
        }else{
            collateralStates[_collection].isSupportAllPools = false;

            for (uint i = 0; i < _pools.length; i++){
                collateralStates[_collection].supportPools[_pools[i]] = true;
            }
        }
    }

    function setOracle(address _oracle) external onlyAdmin{

        oracle = IOracle(_oracle);
    }

    function setXNFT(address _xNFT) external onlyAdmin{

        xNFT = IXNFT(_xNFT);
    }

    function setLiquidityMining(ILiquidityMining _liquidityMining) external onlyAdmin{

        liquidityMining = _liquidityMining;
    }

    function setPendingAdmin(address newPendingAdmin) external onlyAdmin{

        pendingAdmin = newPendingAdmin;
    }

    function acceptAdmin() external{

        require(msg.sender == pendingAdmin, "only pending admin could accept");
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function setPause(address xToken, uint256 index, bool isPause) external onlyAdmin{

        xTokenPausedMap[xToken][index] = isPause;
    }

    modifier onlyAdmin(){

        require(msg.sender == admin, "admin auth");
        _;
    }

    modifier whenNotPaused(address xToken, uint256 index) {

        require(!xTokenPausedMap[xToken][index], "Pausable: paused");
        _;
    }
}