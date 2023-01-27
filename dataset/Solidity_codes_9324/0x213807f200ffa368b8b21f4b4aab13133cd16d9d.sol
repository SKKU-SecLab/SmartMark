

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
        return !AddressUpgradeable.isContract(address(this));
    }
}




            

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




            
pragma solidity 0.6.12;

interface IETHGateway {

  function withdrawETH(uint256 amount, address onBehalfOf, bool redeemType, uint256 _cEthBal) external;

}




            
pragma solidity 0.6.12;

interface ICEth {

    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function setExchangeRateStored(uint256 rate) external;

}



            

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}




            

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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




            

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




            
pragma solidity 0.6.12;

interface IJCompoundHelper {


    function getMantissaHelper(uint256 _underDecs, uint256 _cTokenDecs) external pure returns (uint256 mantissa);

    function getCompoundPurePriceHelper(address _cTokenAddress) external view returns (uint256 compoundPrice);

    function getCompoundPriceHelper(address _cTokenAddress, uint256 _underDecs, uint256 _cTokenDecs) external view returns (uint256 compNormPrice);

}



            
pragma solidity 0.6.12;

interface IIncentivesController {

    function trancheANewEnter(address account, address trancheA) external; 

    function trancheBNewEnter(address account, address trancheB) external; 


    function claimRewardsAllMarkets(address _account) external returns (bool);

    function claimRewardSingleMarketTrA(uint256 _idxMarket, address _account) external;

    function claimRewardSingleMarketTrB(uint256 _idxMarket, address _account) external;

}




            
pragma solidity 0.6.12;

library TransferETHHelper {

    function safeTransferETH(address _to, uint256 _value) internal {

        (bool success,) = _to.call{value:_value}(new bytes(0));
        require(success, 'TH ETH_TRANSFER_FAILED');
    }
}




            
pragma solidity 0.6.12;


contract JCompoundStorage is OwnableUpgradeable {


    uint256 public constant PERCENT_DIVIDER = 10000;  // percentage divider for redemption

    struct TrancheAddresses {
        address buyerCoinAddress;       // ETH (ZERO_ADDRESS) or DAI
        address cTokenAddress;          // cETH or cDAI
        address ATrancheAddress;
        address BTrancheAddress;
    }

    struct TrancheParameters {
        uint256 trancheAFixedPercentage;    // fixed percentage (i.e. 4% = 0.04 * 10^18 = 40000000000000000)
        uint256 trancheALastActionBlock;
        uint256 storedTrancheAPrice;
        uint256 trancheACurrentRPB;
        uint16 redemptionPercentage;        // percentage with 2 decimals (divided by 10000, i.e. 95% is 9500)
        uint8 cTokenDecimals;
        uint8 underlyingDecimals;
    }

    address public adminToolsAddress;
    address public feesCollectorAddress;
    address public tranchesDeployerAddress;
    address public compTokenAddress;
    address public comptrollerAddress;
    address public rewardsToken;

    uint256 public tranchePairsCounter;
    uint256 public totalBlocksPerYear; 
    uint32 public redeemTimeout;

    mapping(address => address) public cTokenContracts;
    mapping(uint256 => TrancheAddresses) public trancheAddresses;
    mapping(uint256 => TrancheParameters) public trancheParameters;
    mapping(address => uint256) public lastActivity;

    ICEth public cEthToken;
    IETHGateway public ethGateway;

    mapping(uint256 => bool) public trancheDepositEnabled;
}


contract JCompoundStorageV2 is JCompoundStorage {

    struct StakingDetails {
        uint256 startTime;
        uint256 amount;
    }

    address public incentivesControllerAddress;

    mapping (address => mapping(uint256 => uint256)) public stakeCounterTrA;
    mapping (address => mapping(uint256 => uint256)) public stakeCounterTrB;
    mapping (address => mapping (uint256 => mapping (uint256 => StakingDetails))) public stakingDetailsTrancheA;
    mapping (address => mapping (uint256 => mapping (uint256 => StakingDetails))) public stakingDetailsTrancheB;

    address public jCompoundHelperAddress;
}




            
pragma solidity 0.6.12;

interface IComptrollerLensInterface {

    function claimComp(address) external;

    function compAccrued(address) external view returns (uint);

}




            
pragma solidity 0.6.12;

interface ICErc20 {

    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function exchangeRateStored() external view returns (uint);

    function setExchangeRateStored(uint256 rate) external;

}



            
pragma solidity 0.6.12;

interface IJCompound {

    event TrancheAddedToProtocol(uint256 trancheNum, address trancheA, address trancheB);
    event TrancheATokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 taAmount);
    event TrancheBTokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 tbAmount);
    event TrancheATokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);
    event TrancheBTokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);

    function getSingleTrancheUserStakeCounterTrA(address _user, uint256 _trancheNum) external view returns (uint256);

    function getSingleTrancheUserStakeCounterTrB(address _user, uint256 _trancheNum) external view returns (uint256);

    function getSingleTrancheUserSingleStakeDetailsTrA(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);

    function getSingleTrancheUserSingleStakeDetailsTrB(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);

    function getTrAValue(uint256 _trancheNum) external view returns (uint256 trANormValue);

    function getTrBValue(uint256 _trancheNum) external view returns (uint256);

    function getTotalValue(uint256 _trancheNum) external view returns (uint256);

    function getTrancheACurrentRPB(uint256 _trancheNum) external view returns (uint256);

    function getTrancheAExchangeRate(uint256 _trancheNum) external view returns (uint256);

    function getTrancheBExchangeRate(uint256 _trancheNum, uint256 _newAmount) external view returns (uint256 tbPrice);

}



            
pragma solidity 0.6.12;

interface IJTranchesDeployer {

    function deployNewTrancheATokens(string calldata _nameA, string calldata _symbolA, address _sender, address _rewardToken) external returns (address);

    function deployNewTrancheBTokens(string calldata _nameB, string calldata _symbolB, address _sender, address _rewardToken) external returns (address);

}



            
pragma solidity 0.6.12;

interface IJTrancheTokens {

    function mint(address account, uint256 value) external;

    function burn(uint256 value) external;

    function updateFundsReceived() external;

    function emergencyTokenTransfer(address _token, address _to, uint256 _amount) external;

    function setRewardTokenAddress(address _token) external;

}



            
pragma solidity 0.6.12;

interface IJAdminTools {

    function isAdmin(address account) external view returns (bool);

    function addAdmin(address account) external;

    function removeAdmin(address account) external;

    function renounceAdmin() external;


    event AdminAdded(address account);
    event AdminRemoved(address account);
}



            

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}




            

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity 0.6.12;



contract JCompound is OwnableUpgradeable, ReentrancyGuardUpgradeable, JCompoundStorageV2, IJCompound {

    using SafeMathUpgradeable for uint256;

    function initialize(address _adminTools, 
            address _feesCollector, 
            address _tranchesDepl,
            address _compTokenAddress,
            address _comptrollAddress,
            address _rewardsToken) external initializer() {

        OwnableUpgradeable.__Ownable_init();
        adminToolsAddress = _adminTools;
        feesCollectorAddress = _feesCollector;
        tranchesDeployerAddress = _tranchesDepl;
        compTokenAddress = _compTokenAddress;
        comptrollerAddress = _comptrollAddress;
        rewardsToken = _rewardsToken;
        redeemTimeout = 3; //default
        totalBlocksPerYear = 2102400; // same number like in Compound protocol
    }

    function setConstantsValues(uint256 _trNum, uint16 _redemPerc, uint32 _redemTimeout, uint256 _blocksPerYear) external onlyAdmins {

        trancheParameters[_trNum].redemptionPercentage = _redemPerc;
        redeemTimeout = _redemTimeout;
        totalBlocksPerYear = _blocksPerYear;
    }

    function setETHGateway(address _ethGateway) external onlyAdmins {

        ethGateway = IETHGateway(_ethGateway);
    }

    function setincentivesControllerAddress(address _incentivesController) external onlyAdmins {

        incentivesControllerAddress = _incentivesController;
    }

    function setJCompoundHelperAddress(address _helper) external onlyAdmins {

        jCompoundHelperAddress = _helper;
    }

    modifier onlyAdmins() {

        require(IJAdminTools(adminToolsAddress).isAdmin(msg.sender), "!Admin");
        _;
    }

    fallback() external payable {}
    receive() external payable {}

    function setNewEnvironment(address _adminTools, 
            address _feesCollector, 
            address _tranchesDepl,
            address _compTokenAddress,
            address _comptrollAddress,
            address _rewardsToken) external onlyOwner {

        require((_adminTools != address(0)) && (_feesCollector != address(0)) && 
            (_tranchesDepl != address(0)) && (_comptrollAddress != address(0)) && (_compTokenAddress != address(0)), "ChkAddress");
        adminToolsAddress = _adminTools;
        feesCollectorAddress = _feesCollector;
        tranchesDeployerAddress = _tranchesDepl;
        compTokenAddress = _compTokenAddress;
        comptrollerAddress = _comptrollAddress;
        rewardsToken = _rewardsToken;
    }

    function setCEtherContract(address _cEtherContract) external onlyAdmins {

        cEthToken = ICEth(_cEtherContract);
        cTokenContracts[address(0)] = _cEtherContract;
    }

    function setCTokenContract(address _erc20Contract, address _cErc20Contract) external onlyAdmins {

        cTokenContracts[_erc20Contract] = _cErc20Contract;
    }

    function isCTokenAllowed(address _erc20Contract) public view returns (bool) {

        return cTokenContracts[_erc20Contract] != address(0);
    }

    function getCompoundSupplyRPB(uint256 _trancheNum) external view returns (uint256) {

        ICErc20 cToken = ICErc20(cTokenContracts[trancheAddresses[_trancheNum].buyerCoinAddress]);
        return cToken.supplyRatePerBlock();
    }

    function setDecimals(uint256 _trancheNum, uint8 _cTokenDec, uint8 _underlyingDec) external onlyAdmins {

        require((_cTokenDec <= 18) && (_underlyingDec <= 18), "Decs");
        trancheParameters[_trancheNum].cTokenDecimals = _cTokenDec;
        trancheParameters[_trancheNum].underlyingDecimals = _underlyingDec;
    }

    function setTrancheAFixedPercentage(uint256 _trancheNum, uint256 _newTrAPercentage) external onlyAdmins {

        trancheParameters[_trancheNum].trancheAFixedPercentage = _newTrAPercentage;
        trancheParameters[_trancheNum].storedTrancheAPrice = setTrancheAExchangeRate(_trancheNum);
    }

    function addTrancheToProtocol(address _erc20Contract, string memory _nameA, string memory _symbolA, string memory _nameB, 
                string memory _symbolB, uint256 _fixedRpb, uint8 _cTokenDec, uint8 _underlyingDec) external onlyAdmins nonReentrant {

        require(tranchesDeployerAddress != address(0), "!TrDepl");
        require(isCTokenAllowed(_erc20Contract), "!Allow");

        trancheAddresses[tranchePairsCounter].buyerCoinAddress = _erc20Contract;
        trancheAddresses[tranchePairsCounter].cTokenAddress = cTokenContracts[_erc20Contract];
        trancheAddresses[tranchePairsCounter].ATrancheAddress = 
                IJTranchesDeployer(tranchesDeployerAddress).deployNewTrancheATokens(_nameA, _symbolA, msg.sender, rewardsToken);
        trancheAddresses[tranchePairsCounter].BTrancheAddress = 
                IJTranchesDeployer(tranchesDeployerAddress).deployNewTrancheBTokens(_nameB, _symbolB, msg.sender, rewardsToken);
        
        trancheParameters[tranchePairsCounter].cTokenDecimals = _cTokenDec;
        trancheParameters[tranchePairsCounter].underlyingDecimals = _underlyingDec;
        trancheParameters[tranchePairsCounter].trancheAFixedPercentage = _fixedRpb;
        trancheParameters[tranchePairsCounter].trancheALastActionBlock = block.number;
        trancheParameters[tranchePairsCounter].storedTrancheAPrice = 
            IJCompoundHelper(jCompoundHelperAddress).getCompoundPriceHelper(cTokenContracts[_erc20Contract], _underlyingDec, _cTokenDec);

        trancheParameters[tranchePairsCounter].redemptionPercentage = 9950;  //default value 99.5%

        calcRPBFromPercentage(tranchePairsCounter); // initialize tranche A RPB

        emit TrancheAddedToProtocol(tranchePairsCounter, trancheAddresses[tranchePairsCounter].ATrancheAddress, trancheAddresses[tranchePairsCounter].BTrancheAddress);

        tranchePairsCounter = tranchePairsCounter.add(1);
    } 

    function setTrancheDeposit(uint256 _trancheNum, bool _enable) external onlyAdmins {

        trancheDepositEnabled[_trancheNum] = _enable;
    }

    function sendErc20ToCompound(address _erc20Contract, uint256 _numTokensToSupply) internal returns(uint256) {

        address cTokenAddress = cTokenContracts[_erc20Contract];
        require(cTokenAddress != address(0), "!Accept");

        IERC20Upgradeable underlying = IERC20Upgradeable(_erc20Contract);

        ICErc20 cToken = ICErc20(cTokenAddress);

        SafeERC20Upgradeable.safeApprove(underlying, cTokenAddress, _numTokensToSupply);
        require(underlying.allowance(address(this), cTokenAddress) >= _numTokensToSupply, "!AllowCToken");

        uint256 mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }

    function redeemCErc20Tokens(address _erc20Contract, uint256 _amount, bool _redeemType) internal returns (uint256 redeemResult) {

        address cTokenAddress = cTokenContracts[_erc20Contract];
        require(cTokenAddress != address(0),  "!Accept");

        ICErc20 cToken = ICErc20(cTokenAddress);

        if (_redeemType) {
            redeemResult = cToken.redeem(_amount);
        } else {
            redeemResult = cToken.redeemUnderlying(_amount);
        }
        return redeemResult;
    }

    function getTrancheAExchangeRate(uint256 _trancheNum) public view override returns (uint256) {

        return trancheParameters[_trancheNum].storedTrancheAPrice;
    }

    function getTrancheACurrentRPB(uint256 _trancheNum) external view override returns (uint256) {

        return trancheParameters[_trancheNum].trancheACurrentRPB;
    }

    function setTrancheAExchangeRate(uint256 _trancheNum) internal returns (uint256) {

        calcRPBFromPercentage(_trancheNum);
        uint256 deltaBlocks = (block.number).sub(trancheParameters[_trancheNum].trancheALastActionBlock);
        if (deltaBlocks > 0) {
            uint256 deltaPrice = (trancheParameters[_trancheNum].trancheACurrentRPB).mul(deltaBlocks);
            trancheParameters[_trancheNum].storedTrancheAPrice = (trancheParameters[_trancheNum].storedTrancheAPrice).add(deltaPrice);
            trancheParameters[_trancheNum].trancheALastActionBlock = block.number;
        }
        return trancheParameters[_trancheNum].storedTrancheAPrice;
    }

    function calcRPBFromPercentage(uint256 _trancheNum) public returns (uint256) {

        trancheParameters[_trancheNum].trancheACurrentRPB = trancheParameters[_trancheNum].storedTrancheAPrice
            .mul(trancheParameters[_trancheNum].trancheAFixedPercentage).div(totalBlocksPerYear).div(1e18);
        return trancheParameters[_trancheNum].trancheACurrentRPB;
    }

    function getTrAValue(uint256 _trancheNum) public view override returns (uint256 trANormValue) {

        uint256 totASupply = IERC20Upgradeable(trancheAddresses[_trancheNum].ATrancheAddress).totalSupply();
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 storedAPrice = trancheParameters[_trancheNum].storedTrancheAPrice;
        trANormValue = totASupply.mul(storedAPrice).div(1e18).div(10 ** diffDec);
        return trANormValue;
    }

    function getTrBValue(uint256 _trancheNum) external view override returns (uint256) {

        uint256 totProtValue = getTotalValue(_trancheNum);
        uint256 totTrAValue = getTrAValue(_trancheNum);
        if (totProtValue > totTrAValue) {
            return totProtValue.sub(totTrAValue);
        } else
            return 0;
    }

    function getTotalValue(uint256 _trancheNum) public view override returns (uint256) {

        address cTokenAddress = trancheAddresses[_trancheNum].cTokenAddress;
        uint256 underDecs = uint256(trancheParameters[_trancheNum].underlyingDecimals);
        uint256 cTokenDecs = uint256(trancheParameters[_trancheNum].cTokenDecimals);
        uint256 compNormPrice = IJCompoundHelper(jCompoundHelperAddress).getCompoundPriceHelper(cTokenAddress, underDecs, cTokenDecs);
        uint256 mantissa = IJCompoundHelper(jCompoundHelperAddress).getMantissaHelper(underDecs, cTokenDecs);
        if (mantissa < 18) {
            compNormPrice = compNormPrice.div(10 ** (uint256(18).sub(mantissa)));
        } else {
            compNormPrice = IJCompoundHelper(jCompoundHelperAddress).getCompoundPurePriceHelper(cTokenAddress);
        }
        uint256 totProtSupply = getTokenBalance(trancheAddresses[_trancheNum].cTokenAddress);
        return totProtSupply.mul(compNormPrice).div(1e18);
    }

    function getTrancheBExchangeRate(uint256 _trancheNum, uint256 _newAmount) public view override returns (uint256 tbPrice) {

        uint256 totTrBValue;

        uint256 totBSupply = IERC20Upgradeable(trancheAddresses[_trancheNum].BTrancheAddress).totalSupply(); // 18 decimals
        uint256 underlyingDec = uint256(trancheParameters[_trancheNum].underlyingDecimals);
        uint256 normAmount = _newAmount;
        if (underlyingDec < 18)
            normAmount = _newAmount.mul(10 ** uint256(18).sub(underlyingDec));
        uint256 newBSupply = totBSupply.add(normAmount); // 18 decimals

        uint256 totProtValue = getTotalValue(_trancheNum).add(_newAmount); //underlying token decimals
        uint256 totTrAValue = getTrAValue(_trancheNum); //underlying token decimals
        if (totProtValue >= totTrAValue)
            totTrBValue = totProtValue.sub(totTrAValue); //underlying token decimals
        else
            totTrBValue = 0;
        if (underlyingDec < 18 && totTrBValue > 0) {
            totTrBValue = totTrBValue.mul(10 ** (uint256(18).sub(underlyingDec)));
        }
        if (totTrBValue > 0 && newBSupply > 0) {
            tbPrice = totTrBValue.mul(1e18).div(newBSupply);
        } else
            tbPrice = uint256(1e18);

        return tbPrice;
    }

    function setTrAStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external onlyAdmins {

        stakeCounterTrA[_account][_trancheNum] = _stkNum;
        StakingDetails storage details = stakingDetailsTrancheA[_account][_trancheNum][_stkNum];
        details.startTime = _time;
        details.amount = _amount;
    }

    function decreaseTrancheATokenFromStake(uint256 _trancheNum, uint256 _amount) internal {

        uint256 senderCounter = stakeCounterTrA[msg.sender][_trancheNum];
        uint256 tmpAmount = _amount;
        for (uint i = 1; i <= senderCounter; i++) {
            StakingDetails storage details = stakingDetailsTrancheA[msg.sender][_trancheNum][i];
            if (details.amount > 0) {
                if (details.amount <= tmpAmount) {
                    tmpAmount = tmpAmount.sub(details.amount);
                    details.amount = 0;
                } else {
                    details.amount = details.amount.sub(tmpAmount);
                    tmpAmount = 0;
                }
            }
            if (tmpAmount == 0)
                break;
        }
    }

    function getSingleTrancheUserStakeCounterTrA(address _user, uint256 _trancheNum) external view override returns (uint256) {

        return stakeCounterTrA[_user][_trancheNum];
    }

    function getSingleTrancheUserSingleStakeDetailsTrA(address _user, uint256 _trancheNum, uint256 _num) external view override returns (uint256, uint256) {

        return (stakingDetailsTrancheA[_user][_trancheNum][_num].startTime, stakingDetailsTrancheA[_user][_trancheNum][_num].amount);
    }

    function setTrBStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external onlyAdmins {

        stakeCounterTrB[_account][_trancheNum] = _stkNum;
        StakingDetails storage details = stakingDetailsTrancheB[_account][_trancheNum][_stkNum];
        details.startTime = _time;
        details.amount = _amount; 
    }

    function decreaseTrancheBTokenFromStake(uint256 _trancheNum, uint256 _amount) internal {

        uint256 senderCounter = stakeCounterTrB[msg.sender][_trancheNum];
        uint256 tmpAmount = _amount;
        for (uint i = 1; i <= senderCounter; i++) {
            StakingDetails storage details = stakingDetailsTrancheB[msg.sender][_trancheNum][i];
            if (details.amount > 0) {
                if (details.amount <= tmpAmount) {
                    tmpAmount = tmpAmount.sub(details.amount);
                    details.amount = 0;
                } else {
                    details.amount = details.amount.sub(tmpAmount);
                    tmpAmount = 0;
                }
            }
            if (tmpAmount == 0)
                break;
        }
    }

    function getSingleTrancheUserStakeCounterTrB(address _user, uint256 _trancheNum) external view override returns (uint256) {

        return stakeCounterTrB[_user][_trancheNum];
    }

    function getSingleTrancheUserSingleStakeDetailsTrB(address _user, uint256 _trancheNum, uint256 _num) external view override returns (uint256, uint256) {

        return (stakingDetailsTrancheB[_user][_trancheNum][_num].startTime, stakingDetailsTrancheB[_user][_trancheNum][_num].amount);
    }

    function buyTrancheAToken(uint256 _trancheNum, uint256 _amount) external payable nonReentrant {

        require(trancheDepositEnabled[_trancheNum], "!Deposit");
        address cTokenAddress = trancheAddresses[_trancheNum].cTokenAddress;
        address underTokenAddress = trancheAddresses[_trancheNum].buyerCoinAddress;
        uint256 prevCompTokenBalance = getTokenBalance(cTokenAddress);
        if (underTokenAddress == address(0)){
            require(msg.value == _amount, "!Amount");
            TransferETHHelper.safeTransferETH(address(this), _amount);
            cEthToken.mint{value: _amount}();
        } else {
            require(IERC20Upgradeable(underTokenAddress).allowance(msg.sender, address(this)) >= _amount, "!Allowance");
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(underTokenAddress), msg.sender, address(this), _amount);
            sendErc20ToCompound(underTokenAddress, _amount);
        }
        uint256 newCompTokenBalance = getTokenBalance(cTokenAddress);
        setTrancheAExchangeRate(_trancheNum);
        uint256 taAmount;
        if (newCompTokenBalance > prevCompTokenBalance) {
            uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
            uint256 normAmount = _amount.mul(10 ** diffDec);
            taAmount = normAmount.mul(1e18).div(trancheParameters[_trancheNum].storedTrancheAPrice);
            IIncentivesController(incentivesControllerAddress).trancheANewEnter(msg.sender, trancheAddresses[_trancheNum].ATrancheAddress);
            IJTrancheTokens(trancheAddresses[_trancheNum].ATrancheAddress).mint(msg.sender, taAmount);
        } else {
            taAmount = 0;
        }

        stakeCounterTrA[msg.sender][_trancheNum] = stakeCounterTrA[msg.sender][_trancheNum].add(1);
        StakingDetails storage details = stakingDetailsTrancheA[msg.sender][_trancheNum][stakeCounterTrA[msg.sender][_trancheNum]];
        details.startTime = block.timestamp;
        details.amount = taAmount;

        lastActivity[msg.sender] = block.number;
        emit TrancheATokenMinted(_trancheNum, msg.sender, _amount, taAmount);
    }

    function redeemTrancheAToken(uint256 _trancheNum, uint256 _amount) external nonReentrant {

        require((block.number).sub(lastActivity[msg.sender]) >= redeemTimeout, "!Timeout");
        address aTrancheAddress = trancheAddresses[_trancheNum].ATrancheAddress;
        require(IERC20Upgradeable(aTrancheAddress).allowance(msg.sender, address(this)) >= _amount, "!Allowance");
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(aTrancheAddress), msg.sender, address(this), _amount);

        uint256 oldBal;
        uint256 diffBal;
        uint256 userAmount;
        uint256 feesAmount;
        setTrancheAExchangeRate(_trancheNum);
        uint256 taAmount = _amount.mul(trancheParameters[_trancheNum].storedTrancheAPrice).div(1e18);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = taAmount.div(10 ** diffDec);

        address cTokenAddress = trancheAddresses[_trancheNum].cTokenAddress;
        uint256 cTokenBal = getTokenBalance(cTokenAddress); // needed for emergency
        address underTokenAddress = trancheAddresses[_trancheNum].buyerCoinAddress;
        uint256 redeemPerc = uint256(trancheParameters[_trancheNum].redemptionPercentage);
        if (underTokenAddress == address(0)) {
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(cTokenAddress), address(ethGateway), cTokenBal);
            oldBal = getEthBalance();
            ethGateway.withdrawETH(normAmount, address(this), false, cTokenBal);
            diffBal = getEthBalance().sub(oldBal);
            userAmount = diffBal.mul(redeemPerc).div(PERCENT_DIVIDER);
            TransferETHHelper.safeTransferETH(msg.sender, userAmount);
            if (diffBal != userAmount) {
                feesAmount = diffBal.sub(userAmount);
                TransferETHHelper.safeTransferETH(feesCollectorAddress, feesAmount);
            }   
        } else {
            oldBal = getTokenBalance(underTokenAddress);
            uint256 compoundRetCode = redeemCErc20Tokens(underTokenAddress, normAmount, false);
            if(compoundRetCode != 0) {
                redeemCErc20Tokens(underTokenAddress, cTokenBal, true); 
            }
            diffBal = getTokenBalance(underTokenAddress).sub(oldBal);
            userAmount = diffBal.mul(redeemPerc).div(PERCENT_DIVIDER);
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(underTokenAddress), msg.sender, userAmount);
            if (diffBal != userAmount) {
                feesAmount = diffBal.sub(userAmount);
                SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(underTokenAddress), feesCollectorAddress, feesAmount);
            }
        }

        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(msg.sender);

        if (rewClaimCompleted && _amount > 0)
            decreaseTrancheATokenFromStake(_trancheNum, _amount);
     
        IJTrancheTokens(aTrancheAddress).burn(_amount);

        lastActivity[msg.sender] = block.number;
        emit TrancheATokenRedemption(_trancheNum, msg.sender, 0, userAmount, feesAmount);
    }

    function buyTrancheBToken(uint256 _trancheNum, uint256 _amount) external payable nonReentrant {

        require(trancheDepositEnabled[_trancheNum], "!Deposit");
        address cTokenAddress = trancheAddresses[_trancheNum].cTokenAddress;
        address underTokenAddress = trancheAddresses[_trancheNum].buyerCoinAddress;
        uint256 prevCompTokenBalance = getTokenBalance(cTokenAddress);
        if (trancheAddresses[_trancheNum].buyerCoinAddress == address(0)) {
            require(msg.value == _amount, "!Amount");
        }
        setTrancheAExchangeRate(_trancheNum);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = _amount.mul(10 ** diffDec);
        uint256 tbAmount = normAmount.mul(1e18).div(getTrancheBExchangeRate(_trancheNum, _amount));
        if (underTokenAddress == address(0)) {
            TransferETHHelper.safeTransferETH(address(this), _amount);
            cEthToken.mint{value: _amount}();
        } else {
            require(IERC20Upgradeable(underTokenAddress).allowance(msg.sender, address(this)) >= _amount, "!Allowance");
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(underTokenAddress), msg.sender, address(this), _amount);
            sendErc20ToCompound(underTokenAddress, _amount);
        }
        uint256 newCompTokenBalance = getTokenBalance(cTokenAddress);
        if (newCompTokenBalance > prevCompTokenBalance) {
            IIncentivesController(incentivesControllerAddress).trancheBNewEnter(msg.sender, trancheAddresses[_trancheNum].BTrancheAddress);
            IJTrancheTokens(trancheAddresses[_trancheNum].BTrancheAddress).mint(msg.sender, tbAmount);
        } else 
            tbAmount = 0;

        stakeCounterTrB[msg.sender][_trancheNum] = stakeCounterTrB[msg.sender][_trancheNum].add(1);
        StakingDetails storage details = stakingDetailsTrancheB[msg.sender][_trancheNum][stakeCounterTrB[msg.sender][_trancheNum]];
        details.startTime = block.timestamp;
        details.amount = tbAmount;     

        lastActivity[msg.sender] = block.number;
        emit TrancheBTokenMinted(_trancheNum, msg.sender, _amount, tbAmount);
    }

    function redeemTrancheBToken(uint256 _trancheNum, uint256 _amount) external nonReentrant {

        require((block.number).sub(lastActivity[msg.sender]) >= redeemTimeout, "!Timeout");
        address bTrancheAddress = trancheAddresses[_trancheNum].BTrancheAddress;
        require(IERC20Upgradeable(bTrancheAddress).allowance(msg.sender, address(this)) >= _amount, "!Allowance");
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(bTrancheAddress), msg.sender, address(this), _amount);

        uint256 oldBal;
        uint256 diffBal;
        uint256 userAmount;
        uint256 feesAmount;
        setTrancheAExchangeRate(_trancheNum);
        uint256 tbAmount = _amount.mul(getTrancheBExchangeRate(_trancheNum, 0)).div(1e18);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = tbAmount.div(10 ** diffDec);

        address cTokenAddress = trancheAddresses[_trancheNum].cTokenAddress;
        uint256 cTokenBal = getTokenBalance(cTokenAddress); // needed for emergency
        address underTokenAddress = trancheAddresses[_trancheNum].buyerCoinAddress;
        uint256 redeemPerc = uint256(trancheParameters[_trancheNum].redemptionPercentage);
        if (underTokenAddress == address(0)){
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(cTokenAddress), address(ethGateway), cTokenBal);
            oldBal = getEthBalance();
            ethGateway.withdrawETH(normAmount, address(this), false, cTokenBal);
            diffBal = getEthBalance().sub(oldBal);
            userAmount = diffBal.mul(redeemPerc).div(PERCENT_DIVIDER);
            TransferETHHelper.safeTransferETH(msg.sender, userAmount);
            if (diffBal != userAmount) {
                feesAmount = diffBal.sub(userAmount);
                TransferETHHelper.safeTransferETH(feesCollectorAddress, feesAmount);
            }   
        } else {
            oldBal = getTokenBalance(underTokenAddress);
            require(redeemCErc20Tokens(underTokenAddress, normAmount, false) == 0, "!cTokenAnswer");
            diffBal = getTokenBalance(underTokenAddress);
            userAmount = diffBal.mul(redeemPerc).div(PERCENT_DIVIDER);
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(underTokenAddress), msg.sender, userAmount);
            if (diffBal != userAmount) {
                feesAmount = diffBal.sub(userAmount);
                SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(underTokenAddress), feesCollectorAddress, feesAmount);
            }   
        }

        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(msg.sender);

        if (rewClaimCompleted && _amount > 0)
            decreaseTrancheBTokenFromStake(_trancheNum, _amount);

        IJTrancheTokens(bTrancheAddress).burn(_amount);

        lastActivity[msg.sender] = block.number;
        emit TrancheBTokenRedemption(_trancheNum, msg.sender, 0, userAmount, feesAmount);
    }

    function redeemCTokenAmount(uint256 _trancheNum, uint256 _cTokenAmount) external onlyAdmins nonReentrant {

        uint256 oldBal;
        uint256 diffBal;
        address underTokenAddress = trancheAddresses[_trancheNum].buyerCoinAddress;
        uint256 cTokenBal = getTokenBalance(trancheAddresses[_trancheNum].cTokenAddress); // needed for emergency
        if (underTokenAddress == address(0)) {
            oldBal = getEthBalance();
            ethGateway.withdrawETH(_cTokenAmount, address(this), true, cTokenBal);
            diffBal = getEthBalance().sub(oldBal);
            TransferETHHelper.safeTransferETH(feesCollectorAddress, diffBal);
        } else {
            oldBal = getTokenBalance(underTokenAddress);
            require(redeemCErc20Tokens(underTokenAddress, _cTokenAmount, true) == 0, "!cTokenAnswer");
            diffBal = getTokenBalance(underTokenAddress);
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(underTokenAddress), feesCollectorAddress, diffBal);
        }
    }

    function getTokenBalance(address _tokenContract) public view returns (uint256) {

        return IERC20Upgradeable(_tokenContract).balanceOf(address(this));
    }

    function getEthBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function transferTokenToFeesCollector(address _tokenContract, uint256 _amount) external onlyAdmins {

        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_tokenContract), feesCollectorAddress, _amount);
    }

    function withdrawEthToFeesCollector(uint256 _amount) external onlyAdmins {

        TransferETHHelper.safeTransferETH(feesCollectorAddress, _amount);
    }

    function getTotalCompAccrued() public view onlyAdmins returns (uint256) {

        return IComptrollerLensInterface(comptrollerAddress).compAccrued(address(this));
    }

    function claimTotalCompAccruedToReceiver(address _receiver) external onlyAdmins nonReentrant {

        uint256 totAccruedAmount = getTotalCompAccrued();
        if (totAccruedAmount > 0) {
            IComptrollerLensInterface(comptrollerAddress).claimComp(address(this));
            uint256 amount = IERC20Upgradeable(compTokenAddress).balanceOf(address(this));
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(compTokenAddress), _receiver, amount);
        }
    }
}