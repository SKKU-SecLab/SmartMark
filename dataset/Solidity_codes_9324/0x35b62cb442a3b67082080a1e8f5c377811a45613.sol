pragma solidity ^0.6.4;


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
}pragma solidity ^0.6.4;

interface EIP20Interface {

    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint8);

    function totalSupply() external view returns(uint256);

    function balanceOf(address owner) external view returns(uint256);

    function allowance(address owner, address spender) external view returns(uint256);

    function approve(address usr, uint amount) external returns(bool);

    function transfer(address dst, uint256 amount) external returns(bool);

    function transferFrom(address src, address dst, uint amount) external returns(bool);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}pragma solidity ^0.6.4;

interface AucReceiverInterface {

	function tokenFallback(address from, uint256 amount, bytes calldata data) external;

}pragma solidity ^0.6.4;

interface UniswapFactoryInterface {

    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}pragma solidity ^0.6.4;

interface DPiggyDataInterface {

    function auc() external view returns(address);

    function dai() external view returns(address);

    function compound() external view returns(address);

    function exchange() external view returns(address);

    function percentagePrecision() external view returns(uint256);

}

interface DPiggyInterface is DPiggyDataInterface {

    function executionFee(uint256 baseTime) external view returns(uint256);

    function escrowStart(address user) external view returns(uint256);

}pragma solidity ^0.6.4;

interface DPiggyAssetInterface {

    function getUserProfitsAndFeeAmount(address user) external view returns(uint256, uint256, uint256);

    function setMinimumTimeBetweenExecutions(uint256 time) external;

    function deposit(address user, uint256 amount) external;

    function addEscrow(address user) external returns(bool);

}pragma solidity ^0.6.4;

interface DPiggyBaseProxyInterface {

    function setImplementation(address newImplementation, bytes calldata data) external payable;

    function setAdmin(address newAdmin) external;

}pragma solidity ^0.6.4;


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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.6.4;

contract DPiggyBaseProxyData {

    
    event SetProxyImplementation(address indexed newImplementation, address oldImplementation);
    
    event SetProxyAdmin(address indexed newAdmin, address oldAdmin);
    
    modifier onlyAdmin() {

        require(msg.sender == admin);
        _;
    }
    
    address public implementation;
    
    address public admin;
}
pragma solidity ^0.6.4;


contract DPiggyBaseProxy is DPiggyBaseProxyData, DPiggyBaseProxyInterface {


    constructor(address _admin, address _implementation, bytes memory data) public payable {
        admin = _admin;
        _setImplementation(_implementation, data);
    } 
  
    fallback() external payable {
        address addr = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), addr, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
  
    function proxyType() public pure returns(uint256) {

        return 2; 
    }
    
    function setImplementation(address newImplementation, bytes calldata data) onlyAdmin external override(DPiggyBaseProxyInterface) payable {

        require(Address.isContract(newImplementation));
        address oldImplementation = implementation;
        _setImplementation(newImplementation, data);
        emit SetProxyImplementation(newImplementation, oldImplementation);
    }
    
    function setAdmin(address newAdmin) onlyAdmin external override(DPiggyBaseProxyInterface) {

        require(newAdmin != address(0));
        address oldAdmin = admin;
        admin = newAdmin;
        emit SetProxyAdmin(newAdmin, oldAdmin);
    }
    
    function _setImplementation(address _implementation, bytes memory data) internal {

        implementation = _implementation;
        if (data.length > 0) {
            (bool success,) = _implementation.delegatecall(data);
            assert(success);
        }
    }
}
pragma solidity ^0.6.4;

contract ReentrancyGuard {

    bool internal _notEntered;

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard:: reentry");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}pragma solidity ^0.6.4;


contract DPiggyAssetData is DPiggyBaseProxyData, ReentrancyGuard {

    
    struct Execution {
        uint256 time;
        
        uint256 rate;
        
        uint256 totalDai;
        
        uint256 totalRedeemed;
        
        uint256 totalBought;
        
        uint256 totalBalance;
        
        uint256 totalFeeDeduction;
        
        uint256 feeAmount;
    }
    
    struct UserData {
        uint256 baseExecutionId;
        
        uint256 baseExecutionAvgRate;
        
        uint256 baseExecutionAccumulatedAmount;
        
        uint256 baseExecutionAccumulatedWeightForRate;
        
        uint256 baseExecutionAmountForFee;
        
        uint256 currentAllocated;
        
        uint256 previousAllocated;
        
        uint256 previousProfit;
        
        uint256 previousAssetAmount;
        
        uint256 previousFeeAmount;
        
        uint256 redeemed;
    }
    
    event SetMinimumTimeBetweenExecutions(uint256 newTime, uint256 oldTime);
    
    event Deposit(address indexed user, uint256 amount, uint256 rate, uint256 baseExecutionId, uint256 baseExecutionAmountForFee);
    
    event Redeem(address indexed user, uint256 amount);
    
    event CompoundRedeem(uint256 indexed executionId, uint256 rate, uint256 totalBalance, uint256 totalRedeemed, uint256 fee, uint256 totalBought, uint256 totalAucBurned);
    
    event Finish(address indexed user, uint256 totalRedeemed, uint256 yield, uint256 fee, uint256 totalAucBurned);
    
    event SetMigration(address previousContract);

    address public tokenAddress;
    
    uint256 public minimumTimeBetweenExecutions;
    
    uint256 public executionId;
    
    uint256 public totalBalance;
    
    uint256 public feeExemptionAmountForAucEscrowed;
    
    bool public isCompound;
    
    mapping(uint256 => uint256) public totalBalanceNormalizedDifference;
    
    mapping(uint256 => uint256) public feeExemptionNormalizedDifference;
    
    mapping(uint256 => uint256) public remainingValueRedeemed;
    
    mapping(uint256 => uint256) public feeExemptionAmountForUserBaseData;
    
    mapping(uint256 => Execution) public executions;
    
    mapping(address => UserData) public usersData;
}
pragma solidity ^0.6.4;


contract DPiggyAssetProxy is DPiggyBaseProxy, DPiggyAssetData {

    constructor(
        address _admin, 
        address _implementation, 
        bytes memory data
    ) public payable DPiggyBaseProxy(_admin, _implementation, data) {
    } 
}pragma solidity ^0.6.4;


contract DPiggyData is DPiggyBaseProxyData, ReentrancyGuard, DPiggyDataInterface {

    
    struct EscrowData {
        uint256 amount;
        
        uint256 time;
    }
    
    struct AssetData {
        address proxy;
        
        bool depositAllowed;
        
        uint256 time;
        
        uint256 minimumDeposit;
    }
    
    event SetDailyFee(uint256 newDailylFee, uint256 oldDailylFee);
    
    event SetMinimumAucToFreeFee(uint256 newMinimumAuc, uint256 oldMinimumAuc);
    
    event SetUserAucEscrow(address indexed user, uint256 amount);
    
    event RedeemUserAucEscrow(address indexed user, uint256 amount);
    
    event SetNewAsset(address indexed tokenAddress, address proxy);
    
    event SetAssetDepositAllowed(address indexed tokenAddress, bool newDepositAllowed, bool oldDepositAllowed);
    
    event SetAssetMinimumDeposit(address indexed tokenAddress, uint256 newMinimumDeposit, uint256 oldMinimumDeposit);

    address public override(DPiggyDataInterface) auc;
    
    address public override(DPiggyDataInterface) dai;
    
    address public override(DPiggyDataInterface) compound;
    
    address public override(DPiggyDataInterface) exchange;
    
    address public uniswapFactory;
    
    address public assetImplementation;
    
    uint256 public override(DPiggyDataInterface) percentagePrecision;
    
    uint256 public minimumAucToFreeFee;
    
    uint256 public totalEscrow;
    
    uint256 public maximumDailyFee;
    
    uint256 public dailyFee;
    
    uint256 public numberOfAssets;
    
    address[] public assets;
    
    mapping(address => EscrowData) public usersEscrow;
    
    mapping(address => AssetData) public assetsData;
}pragma solidity ^0.6.4;


contract DPiggy is DPiggyData, DPiggyInterface, AucReceiverInterface {

    using SafeMath for uint256;

    function init(
        uint256 _percentagePrecision,
        uint256 _dailyFee,
        uint256 _maximumDailyFee,
        uint256 _minimumAucToFreeFee,
        address _dai,
        address _compound,
        address _uniswapFactory,
        address _auc,
        address _assetImplementation) public {

        
        assert(
            assetImplementation == address(0) && 
            auc == address(0) && 
            dai == address(0) && 
            percentagePrecision == 0 && 
            maximumDailyFee == 0
        );
        
        require(_dailyFee <= _maximumDailyFee, "DPiggy::init: Invalid fee");
        
        percentagePrecision = _percentagePrecision;
        dailyFee = _dailyFee;
        maximumDailyFee = _maximumDailyFee;
        minimumAucToFreeFee = _minimumAucToFreeFee;
        dai = _dai;
        auc = _auc;
        compound = _compound;
        assetImplementation = _assetImplementation;
        uniswapFactory = _uniswapFactory;
        
        setExchange();
        
        _notEntered = true;
    }
    
    receive() external payable {
        revert();
    }
    
    function executionFee(uint256 baseTime) external override(DPiggyInterface) view returns(uint256) {

        uint256 daysAmount = baseTime / 86400;
        if (daysAmount == 0) {
            return 0;
        } else {
            uint256 pow = percentagePrecision + dailyFee;
            uint256 base = pow;
            for (uint256 i = 1; i < daysAmount; ++i) {
                pow = (base * pow / percentagePrecision);
            }
            return pow - percentagePrecision;
        }
    }
    
    function escrowStart(address user) external override(DPiggyInterface) view returns(uint256) {

        EscrowData storage escrow = usersEscrow[user];
        return escrow.time;
    }
    
    function getTotalInvested(address tokenAddress) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("totalBalance()"));
    }
    
    function getMinimumTimeForNextExecution(address tokenAddress) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("getMinimumTimeForNextExecution()"));
    }
    
    function getMinimumDeposit(address tokenAddress) external view returns(uint256) {

        AssetData storage assetData = assetsData[tokenAddress];
        if (assetData.time > 0) {
            return assetData.minimumDeposit;
        }
        return 0;
    }
    
    function getUserProfitsAndFeeAmount(address tokenAddress, address user) external view returns(uint256, uint256, uint256) {

        AssetData storage assetData = assetsData[tokenAddress];
        if (assetData.time > 0) {
            return DPiggyAssetInterface(assetData.proxy).getUserProfitsAndFeeAmount(user);
        }
        return (0, 0, 0);
    }
    
    function getUserEstimatedCurrentProfitWithoutFee(address tokenAddress, address user) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("getUserEstimatedCurrentProfitWithoutFee(address)", user));
    }
    
    function getUserEstimatedCurrentFee(address tokenAddress, address user, uint256 time) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("getUserEstimatedCurrentFee(address,uint256)", user, time));
    }
    
    function getUserAssetRedeemed(address tokenAddress, address user) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("getUserAssetRedeemed(address)", user));
    }
    
    function getUserTotalInvested(address tokenAddress, address user) external view returns(uint256) {

        return _getValueFromAsset(tokenAddress, abi.encodeWithSignature("getUserTotalInvested(address)", user));
    }
    
    function setExchange() public {

        exchange = UniswapFactoryInterface(uniswapFactory).getExchange(dai);  
    }
    
    function setDailyFee(uint256 _dailyFee) onlyAdmin external {

        require(_dailyFee <= maximumDailyFee, "DPiggy::setDailyFee: Invalid fee");
        uint256 oldDailyFee = dailyFee;
        dailyFee = _dailyFee;
        emit SetDailyFee(_dailyFee, oldDailyFee);
    }
    
    function setMinimumAucToFreeFee(uint256 _minimumAucToFreeFee) onlyAdmin external {

        uint256 oldMinimumAucToFreeFee = minimumAucToFreeFee;
        minimumAucToFreeFee = _minimumAucToFreeFee;
        emit SetMinimumAucToFreeFee(_minimumAucToFreeFee, oldMinimumAucToFreeFee);
    }
    
    function setAssetImplementation(address _assetImplementation, bytes calldata updateData) onlyAdmin external payable {

        for (uint256 i = 0; i < assets.length; i++) {
            AssetData storage assetData = assetsData[assets[i]];
            DPiggyBaseProxyInterface(assetData.proxy).setImplementation(_assetImplementation, updateData);
        }
        
        assetImplementation = _assetImplementation;
    }
    
    function migrateAssetProxy(address tokenAddress, address _assetImplementation, address[] calldata users) onlyAdmin external {

        AssetData storage assetData = assetsData[tokenAddress];
        require(assetData.time > 0, "DPiggy::migrateAssetProxy: Invalid tokenAddress");
        
        bytes memory initData = abi.encodeWithSignature("initMigratingData(address,address[])", assetData.proxy, users);    
        address newProxy = address(new DPiggyAssetProxy(address(this), _assetImplementation, initData));
        
        bytes memory resignData = abi.encodeWithSignature("resignAssetForMigration(address[])", users);
        (bool success, bytes memory returnData) = assetData.proxy.call(resignData);
        assert(success);
        uint256[] memory amounts = _getUint256(returnData);
        
        if (amounts[0] > 0) {
            assert(EIP20Interface(compound).transfer(newProxy, amounts[0]));
        }
        if (amounts[1] > 0) {
            if (tokenAddress != address(0)) {
                assert(EIP20Interface(tokenAddress).transfer(newProxy, amounts[1]));
            } else {
                Address.toPayable(newProxy).transfer(amounts[1]);
            }
        }
        
        assetData.proxy = newProxy;
    }
    
    function createAsset(
        address tokenAddress, 
        uint256 minimumDeposit,
        bytes calldata creationData
    ) onlyAdmin external payable {     

        
        AssetData storage assetData = assetsData[tokenAddress];
        require(assetData.time == 0, "DPiggy::createAsset: Asset already exists");
        assetData.time = now;
        assetData.depositAllowed = false;
        assetData.minimumDeposit = minimumDeposit;
        assetData.proxy = address(new DPiggyAssetProxy(address(this), assetImplementation, creationData));
        
        assets.push(tokenAddress);
        numberOfAssets++;
        
        emit SetNewAsset(tokenAddress, assetData.proxy); 
    }
    
    function setAssetsDepositAllowed(address[] calldata tokenAddresses, bool[] calldata allowed) onlyAdmin external {

        require(tokenAddresses.length > 0, "DPiggy::setAssetsDepositAllowed: tokenAddresses is required");
        require(tokenAddresses.length == allowed.length, "DPiggy::setAssetsDepositAllowed: Invalid data");
        
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            AssetData storage assetData = assetsData[tokenAddresses[i]];
            if (assetData.time > 0) {
                bool oldDepositAllowed = assetData.depositAllowed;
                assetData.depositAllowed = allowed[i];
                emit SetAssetDepositAllowed(tokenAddresses[i], allowed[i], oldDepositAllowed);
            }
        }   
    }
    
    function setAssetsMinimumDeposit(address[] calldata tokenAddresses, uint256[] calldata minimumDeposits) onlyAdmin external {

        require(tokenAddresses.length > 0, "DPiggy::setAssetsMinimumDeposit: tokenAddresses is required");
        require(tokenAddresses.length == minimumDeposits.length, "DPiggy::setAssetsMinimumDeposit: Invalid data");
        
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            AssetData storage assetData = assetsData[tokenAddresses[i]];
            if (assetData.time > 0) {
                uint256 oldMinimumDeposit = assetData.minimumDeposit;
                assetData.minimumDeposit = minimumDeposits[i];
                emit SetAssetMinimumDeposit(tokenAddresses[i], minimumDeposits[i], oldMinimumDeposit);
            }
        }
    }
    
    function setMinimumTimeBetweenExecutions(address tokenAddress, uint256 time) onlyAdmin external {

        AssetData storage assetData = assetsData[tokenAddress];
        require(assetData.time > 0, "DPiggy::setMinimumTimeBetweenExecutions: Invalid tokenAddress");
        DPiggyAssetInterface(assetData.proxy).setMinimumTimeBetweenExecutions(time);  
    }
    
    function forceRedeem(address[] calldata users, address[] calldata tokenAddresses) nonReentrant onlyAdmin external {

        require(users.length > 0, "DPiggy::forceRedeem: users is required");
        
        for (uint256 i = 0; i < users.length; i++) {
            _setAsset(tokenAddresses, abi.encodeWithSignature("forceRedeem(address)", users[i]));
        }
    }
    
    function forceFinish(address[] calldata users, address[] calldata tokenAddresses) nonReentrant onlyAdmin external {

        require(users.length > 0, "DPiggyAssetManager::forceFinish: users is required");
        
        for (uint256 i = 0; i < users.length; i++) {
            _setAsset(tokenAddresses, abi.encodeWithSignature("forceFinish(address)", users[i]));
        }
    }
    
    function forceFinishAll(address[] calldata users) nonReentrant onlyAdmin external {

        require(users.length > 0, "DPiggyAssetManager::forceFinishAll: users is required");
        
        for (uint256 i = 0; i < users.length; i++) {
            _setAsset(assets, abi.encodeWithSignature("forceFinish(address)", users[i]));
            _redeemEscrow(users[i]);
        }
    }
    
    function deposit(address[] calldata tokenAddresses, uint256[] calldata percentages) nonReentrant external {

        require(tokenAddresses.length > 0, "DPiggy::deposit: Distribution is required");
        require(tokenAddresses.length == percentages.length, "DPiggy::deposit: Invalid distribution");
        
        uint256 amount = EIP20Interface(dai).allowance(msg.sender, address(this));
        
        if (amount > 0) {
            require(EIP20Interface(dai).transferFrom(msg.sender, address(this), amount), "DPiggy::deposit: Error on transfer Dai");
            
            uint256 totalDistribution = 0;
            uint256 remainingAmount = amount;
            for (uint256 i = 0; i < tokenAddresses.length; i++) {
                AssetData storage assetData = assetsData[tokenAddresses[i]];
                
                require(assetData.depositAllowed, "DPiggy::deposit: Deposit denied");
                
                uint256 assetAmount;
                if (i == (tokenAddresses.length - 1)) {
                    assetAmount = remainingAmount;
                } else {
                    assetAmount = amount.mul(percentages[i]).div(percentagePrecision);
                    remainingAmount = remainingAmount.sub(assetAmount);
                } 
                
                require(assetAmount >= assetData.minimumDeposit, "DPiggy::deposit: Invalid amount");
                
                require(EIP20Interface(dai).transfer(assetData.proxy, assetAmount), "DPiggy::deposit: Error on transfer Dai to asset");
                DPiggyAssetInterface(assetData.proxy).deposit(msg.sender, assetAmount);
                
                totalDistribution = totalDistribution.add(percentages[i]);
            }
            
            require(totalDistribution == percentagePrecision, "DPiggy::deposit: Invalid percentage distribution");
        }
    }

    function executeCompoundRedeem(address[] calldata tokenAddresses) nonReentrant external {

        _setAsset(tokenAddresses, abi.encodeWithSignature("executeCompoundRedeem()"));
    }
    
    function redeem(address[] calldata tokenAddresses) nonReentrant external {

        _setAsset(tokenAddresses, abi.encodeWithSignature("forceRedeem(address)", msg.sender));
    }
    
    function finish(address[] calldata tokenAddresses) nonReentrant external {

        _setAsset(tokenAddresses, abi.encodeWithSignature("forceFinish(address)", msg.sender));
    }
    
    function finishAll() nonReentrant external {

        _setAsset(assets, abi.encodeWithSignature("forceFinish(address)", msg.sender));
        _redeemEscrow(msg.sender);
    }
    
    function tokenFallback(address from, uint256 amount, bytes calldata) nonReentrant external override(AucReceiverInterface) {

        require(msg.sender == address(auc), "DPiggy::tokenFallback: Invalid sender");
        require(amount == minimumAucToFreeFee, "DPiggy::tokenFallback: Invalid amount");
        
        EscrowData storage escrow = usersEscrow[from];
        require(escrow.time == 0, "DPiggy::tokenFallback: User already has an escrow");
        
        escrow.time = now;
        escrow.amount = amount;
        totalEscrow = totalEscrow.add(amount);
        
        bool escrowAdded = false;
        for (uint256 i = 0; i < assets.length; i++) {
            AssetData storage assetData = assetsData[assets[i]];
            
            if (DPiggyAssetInterface(assetData.proxy).addEscrow(from) && !escrowAdded) {
                escrowAdded = true;
            }
        }
        require(escrowAdded, "DPiggy::tokenFallback: User without data");
        
        emit SetUserAucEscrow(from, amount);
    }
    
    function _redeemEscrow(address user) internal {

        EscrowData storage escrow = usersEscrow[user];
        uint256 amount = escrow.amount;
        if (amount > 0) {
            escrow.time = 0;
            escrow.amount = 0;
            totalEscrow = totalEscrow.sub(amount);
            require(EIP20Interface(auc).transfer(user, amount), "DPiggy::redeemEscrow: Error on transfer escrow");
            emit RedeemUserAucEscrow(user, amount);
        }
    }
    
    function _setAsset(address[] memory tokenAddresses, bytes memory data) internal {

        require(tokenAddresses.length > 0, "DPiggy::setAsset: tokenAddresses is required");
        
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            AssetData storage assetData = assetsData[tokenAddresses[i]];
            if (assetData.time > 0) {
                (bool success,) = assetData.proxy.call(data);
                assert(success);
            }
        }
    }
    
    function _getValueFromAsset(address tokenAddress, bytes memory data) internal view returns(uint256) {

        AssetData storage assetData = assetsData[tokenAddress];
        if (assetData.time > 0) {
            (bool success, bytes memory returndata) = assetData.proxy.staticcall(data);
            if (success) {
                return abi.decode(returndata, (uint256));
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    
    function _getUint256(bytes memory data) internal pure returns(uint256[] memory) {

        uint256 size = data.length / 32;
        uint256[] memory returnUint = new uint256[](size);
        uint256 offset = 0;
        for (uint256 i = 0; i < size; ++i) {
            bytes32 number;
            for (uint256 j = 0; j < 32; j++) {
                number |= bytes32(data[offset + j] & 0xFF) >> (j * 8);
            }
            returnUint[i] = uint256(number);
            offset += 32;
        }
        return returnUint;
    }
}
