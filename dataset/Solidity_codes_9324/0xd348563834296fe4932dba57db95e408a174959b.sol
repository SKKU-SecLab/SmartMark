
pragma solidity ^0.4.24;

contract Pausable {


    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        paused = true;
        emit Pause(now);
    }

    function _unpause() internal whenPaused {

        paused = false;
        emit Unpause(now);
    }

}

interface IModule {


    function getInitFunction() external pure returns (bytes4);


    function getPermissions() external view returns(bytes32[]);


    function takeFee(uint256 _amount) external returns(bool);


}

interface ISecurityToken {


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);


    function mint(address _investor, uint256 _value) external returns (bool success);


    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);


    function burnFromWithData(address _from, uint256 _value, bytes _data) external;


    function burnWithData(uint256 _value, bytes _data) external;


    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);


    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);


    function getModulesByName(bytes32 _name) external view returns (address[]);


    function getModulesByType(uint8 _type) external view returns (address[]);


    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);


    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);


    function createCheckpoint() external returns (uint256);


    function getInvestors() external view returns (address[]);


    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);


    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);

    
    function currentCheckpointId() external view returns (uint256);


    function investors(uint256 _index) external view returns (address);


    function withdrawERC20(address _tokenContract, uint256 _value) external;


    function changeModuleBudget(address _module, uint256 _budget) external;


    function updateTokenDetails(string _newTokenDetails) external;


    function changeGranularity(uint256 _granularity) external;


    function pruneInvestors(uint256 _start, uint256 _iters) external;


    function freezeTransfers() external;


    function unfreezeTransfers() external;


    function freezeMinting() external;


    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);


    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;


    function archiveModule(address _module) external;


    function unarchiveModule(address _module) external;


    function removeModule(address _module) external;


    function setController(address _controller) external;


    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;


    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;


     function disableController() external;


     function getVersion() external view returns(uint8[]);


     function getInvestorCount() external view returns(uint256);


     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);


     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);


     function granularity() external view returns(uint256);

}

interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);

    function increaseApproval(address _spender, uint _addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ModuleStorage {


    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }
    
    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

}

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Module is IModule, ModuleStorage {


    constructor (address _securityToken, address _polyAddress) public
    ModuleStorage(_securityToken, _polyAddress)
    {
    }

    modifier withPerm(bytes32 _perm) {

        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {

        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {

        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {

        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {

        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {

        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
    }

}

interface ISTO {

    function getTokensSold() external view returns (uint256);

}

contract STOStorage {


    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public pausedTime;
    uint256 public investorCount;
    address public wallet;
    uint256 public totalTokensSold;

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract STO is ISTO, STOStorage, Module, Pausable  {

    using SafeMath for uint256;

    enum FundRaiseType { ETH, POLY, SC }

    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);

    function getRaised(FundRaiseType _fundRaiseType) public view returns (uint256) {

        return fundsRaised[uint8(_fundRaiseType)];
    }

    function pause() public onlyOwner {

        require(now < endTime, "STO has been finalized");
        super._pause();
    }

    function unpause() public onlyOwner {

        super._unpause();
    }

    function _setFundRaiseType(FundRaiseType[] _fundRaiseTypes) internal {

        require(_fundRaiseTypes.length > 0 && _fundRaiseTypes.length <= 3, "Raise type is not specified");
        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;
        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;
        fundRaiseTypes[uint8(FundRaiseType.SC)] = false;
        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {
            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;
        }
        emit SetFundRaiseTypes(_fundRaiseTypes);
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    function reclaimETH() external onlyOwner {

        msg.sender.transfer(address(this).balance);
    }

}

interface IOracle {


    function getCurrencyAddress() external view returns(address);


    function getCurrencySymbol() external view returns(bytes32);


    function getCurrencyDenominated() external view returns(bytes32);


    function getPrice() external view returns(uint256);


}

contract ReclaimTokens is Ownable {


    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Transfer failed");
    }
}

contract PolymathRegistry is ReclaimTokens {


    mapping (bytes32 => address) public storedAddresses;

    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);

    function getAddress(string _nameKey) external view returns(address) {

        bytes32 key = keccak256(bytes(_nameKey));
        require(storedAddresses[key] != address(0), "Invalid address key");
        return storedAddresses[key];
    }

    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {

        bytes32 key = keccak256(bytes(_nameKey));
        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);
        storedAddresses[key] = _newAddress;
    }


}

contract RegistryUpdater is Ownable {


    address public polymathRegistry;
    address public moduleRegistry;
    address public securityTokenRegistry;
    address public featureRegistry;
    address public polyToken;

    constructor (address _polymathRegistry) public {
        require(_polymathRegistry != address(0), "Invalid address");
        polymathRegistry = _polymathRegistry;
    }

    function updateFromRegistry() public onlyOwner {

        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");
        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");
        featureRegistry = PolymathRegistry(polymathRegistry).getAddress("FeatureRegistry");
        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");
    }

}

library DecimalMath {


    using SafeMath for uint256;

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, y), (10 ** 18) / 2) / (10 ** 18);
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, (10 ** 18)), y / 2) / y;
    }

}

contract ReentrancyGuard {


  bool private reentrancyLock = false;

  modifier nonReentrant() {

    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

contract USDTieredSTOStorage {


    struct Tier {
        uint256 rate;

        uint256 rateDiscountPoly;

        uint256 tokenTotal;

        uint256 tokensDiscountPoly;

        uint256 mintedTotal;

        mapping (uint8 => uint256) minted;

        uint256 mintedDiscountPoly;
    }

    struct Investor {
        uint8 accredited;
        uint8 seen;
        uint256 nonAccreditedLimitUSDOverride;
    }

    mapping (bytes32 => mapping (bytes32 => string)) oracleKeys;

    bool public allowBeneficialInvestments = false;

    bool public isFinalized;

    address public reserveWallet;

    address[] public usdTokens;

    uint256 public currentTier;

    uint256 public fundsRaisedUSD;

    mapping (address => uint256) public stableCoinsRaised;

    mapping (address => uint256) public investorInvestedUSD;

    mapping (address => mapping (uint8 => uint256)) public investorInvested;

    mapping (address => Investor) public investors;

    mapping (address => bool) public usdTokenEnabled;

    address[] public investorsList;

    uint256 public nonAccreditedLimitUSD;

    uint256 public minimumInvestmentUSD;

    uint256 public finalAmountReturned;

    Tier[] public tiers;

}

contract USDTieredSTO is USDTieredSTOStorage, STO, ReentrancyGuard {

    using SafeMath for uint256;

    string public constant POLY_ORACLE = "PolyUsdOracle";
    string public constant ETH_ORACLE = "EthUsdOracle";


    event SetAllowBeneficialInvestments(bool _allowed);
    event SetNonAccreditedLimit(address _investor, uint256 _limit);
    event SetAccredited(address _investor, bool _accredited);
    event TokenPurchase(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _tokens,
        uint256 _usdAmount,
        uint256 _tierPrice,
        uint256 _tier
    );
    event FundsReceived(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _usdAmount,
        FundRaiseType _fundRaiseType,
        uint256 _receivedValue,
        uint256 _spentValue,
        uint256 _rate
    );
    event ReserveTokenMint(address indexed _owner, address indexed _wallet, uint256 _tokens, uint256 _latestTier);
    event SetAddresses(
        address indexed _wallet,
        address indexed _reserveWallet,
        address[] _usdTokens
    );
    event SetLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    );
    event SetTimes(
        uint256 _startTime,
        uint256 _endTime
    );
    event SetTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    );


    modifier validETH {

        require(_getOracle(bytes32("ETH"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "ETH not allowed");
        _;
    }

    modifier validPOLY {

        require(_getOracle(bytes32("POLY"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "POLY not allowed");
        _;
    }

    modifier validSC(address _usdToken) {

        require(fundRaiseTypes[uint8(FundRaiseType.SC)] && usdTokenEnabled[_usdToken], "USD not allowed");
        _;
    }


    constructor (address _securityToken, address _polyAddress)
    public
    Module(_securityToken, _polyAddress)
    {
    }

    function configure(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly,
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD,
        FundRaiseType[] _fundRaiseTypes,
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) public onlyFactory {

        oracleKeys[bytes32("ETH")][bytes32("USD")] = ETH_ORACLE;
        oracleKeys[bytes32("POLY")][bytes32("USD")] = POLY_ORACLE;
        require(endTime == 0, "Already configured");
        _modifyTimes(_startTime, _endTime);
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
        _setFundRaiseType(_fundRaiseTypes);
        _modifyAddresses(_wallet, _reserveWallet, _usdTokens);
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    function modifyFunding(FundRaiseType[] _fundRaiseTypes) external onlyOwner {

        require(now < startTime, "STO already started");
        _setFundRaiseType(_fundRaiseTypes);
    }

    function modifyLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    ) external onlyOwner {

        require(now < startTime, "STO already started");
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    function modifyTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    ) external onlyOwner {

        require(now < startTime, "STO already started");
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function modifyTimes(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {

        require(now < startTime, "STO already started");
        _modifyTimes(_startTime, _endTime);
    }

    function modifyAddresses(
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) external onlyOwner {

        _modifyAddresses(_wallet, _reserveWallet, _usdTokens);
    }

    function _modifyLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    ) internal {

        minimumInvestmentUSD = _minimumInvestmentUSD;
        nonAccreditedLimitUSD = _nonAccreditedLimitUSD;
        emit SetLimits(minimumInvestmentUSD, nonAccreditedLimitUSD);
    }

    function _modifyTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    ) internal {

        require(_tokensPerTierTotal.length > 0, "No tiers provided");
        require(_ratePerTier.length == _tokensPerTierTotal.length &&
            _ratePerTierDiscountPoly.length == _tokensPerTierTotal.length &&
            _tokensPerTierDiscountPoly.length == _tokensPerTierTotal.length,
            "Tier data length mismatch"
        );
        delete tiers;
        for (uint256 i = 0; i < _ratePerTier.length; i++) {
            require(_ratePerTier[i] > 0, "Invalid rate");
            require(_tokensPerTierTotal[i] > 0, "Invalid token amount");
            require(_tokensPerTierDiscountPoly[i] <= _tokensPerTierTotal[i], "Too many discounted tokens");
            require(_ratePerTierDiscountPoly[i] <= _ratePerTier[i], "Invalid discount");
            tiers.push(Tier(_ratePerTier[i], _ratePerTierDiscountPoly[i], _tokensPerTierTotal[i], _tokensPerTierDiscountPoly[i], 0, 0));
        }
        emit SetTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function _modifyTimes(
        uint256 _startTime,
        uint256 _endTime
    ) internal {

        require((_endTime > _startTime) && (_startTime > now), "Invalid times");
        startTime = _startTime;
        endTime = _endTime;
        emit SetTimes(_startTime, _endTime);
    }

    function _modifyAddresses(
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) internal {

        require(_wallet != address(0) && _reserveWallet != address(0), "Invalid wallet");
        wallet = _wallet;
        reserveWallet = _reserveWallet;
        _modifyUSDTokens(_usdTokens);
    }

    function _modifyUSDTokens(address[] _usdTokens) internal {

        for(uint256 i = 0; i < usdTokens.length; i++) {
            usdTokenEnabled[usdTokens[i]] = false;
        }
        usdTokens = _usdTokens;
        for(i = 0; i < _usdTokens.length; i++) {
            require(_usdTokens[i] != address(0) && _usdTokens[i] != address(polyToken), "Invalid USD token");
            usdTokenEnabled[_usdTokens[i]] = true;
        }
        emit SetAddresses(wallet, reserveWallet, _usdTokens);
    }


    function finalize() external onlyOwner {

        require(!isFinalized, "STO is finalized");
        isFinalized = true;
        uint256 tempReturned;
        uint256 tempSold;
        uint256 remainingTokens;
        for (uint256 i = 0; i < tiers.length; i++) {
            remainingTokens = tiers[i].tokenTotal.sub(tiers[i].mintedTotal);
            tempReturned = tempReturned.add(remainingTokens);
            tempSold = tempSold.add(tiers[i].mintedTotal);
            if (remainingTokens > 0) {
                tiers[i].mintedTotal = tiers[i].tokenTotal;
            }
        }
        uint256 granularity = ISecurityToken(securityToken).granularity();
        tempReturned = tempReturned.div(granularity);
        tempReturned = tempReturned.mul(granularity);
        require(ISecurityToken(securityToken).mint(reserveWallet, tempReturned), "Error in minting");
        emit ReserveTokenMint(msg.sender, reserveWallet, tempReturned, currentTier);
        finalAmountReturned = tempReturned;
        totalTokensSold = tempSold;
    }

    function changeAccredited(address[] _investors, bool[] _accredited) external onlyOwner {

        require(_investors.length == _accredited.length, "Array mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            if (_accredited[i]) {
                investors[_investors[i]].accredited = uint8(1);
            } else {
                investors[_investors[i]].accredited = uint8(0);
            }
            _addToInvestorsList(_investors[i]);
            emit SetAccredited(_investors[i], _accredited[i]);
        }
    }

    function changeNonAccreditedLimit(address[] _investors, uint256[] _nonAccreditedLimit) external onlyOwner {

        require(_investors.length == _nonAccreditedLimit.length, "Array mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            investors[_investors[i]].nonAccreditedLimitUSDOverride = _nonAccreditedLimit[i];
            _addToInvestorsList(_investors[i]);
            emit SetNonAccreditedLimit(_investors[i], _nonAccreditedLimit[i]);
        }
    }

    function _addToInvestorsList(address _investor) internal {

        if (investors[_investor].seen == uint8(0)) {
            investors[_investor].seen = uint8(1);
            investorsList.push(_investor);
        }
    }

    function getAccreditedData() external view returns (address[], bool[], uint256[]) {

        bool[] memory accrediteds = new bool[](investorsList.length);
        uint256[] memory nonAccreditedLimitUSDOverrides = new uint256[](investorsList.length);
        uint256 i;
        for (i = 0; i < investorsList.length; i++) {
            accrediteds[i] = (investors[investorsList[i]].accredited == uint8(0)? false: true);
            nonAccreditedLimitUSDOverrides[i] = investors[investorsList[i]].nonAccreditedLimitUSDOverride;
        }
        return (investorsList, accrediteds, nonAccreditedLimitUSDOverrides);
    }

    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) external onlyOwner {

        require(_allowBeneficialInvestments != allowBeneficialInvestments);
        allowBeneficialInvestments = _allowBeneficialInvestments;
        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);
    }


    function () external payable {
        buyWithETHRateLimited(msg.sender, 0);
    }

    function buyWithETH(address _beneficiary) external payable {

        buyWithETHRateLimited(_beneficiary, 0);
    }

    function buyWithPOLY(address _beneficiary, uint256 _investedPOLY) external {

        buyWithPOLYRateLimited(_beneficiary, _investedPOLY, 0);
    }

    function buyWithUSD(address _beneficiary, uint256 _investedSC, IERC20 _usdToken) external {

        buyWithUSDRateLimited(_beneficiary, _investedSC, 0, _usdToken);
    }

    function buyWithETHRateLimited(address _beneficiary, uint256 _minTokens) public payable validETH {

        uint256 rate = getRate(FundRaiseType.ETH);
        uint256 initialMinted = getTokensMinted();
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, msg.value, rate, FundRaiseType.ETH);
        require(getTokensMinted().sub(initialMinted) >= _minTokens, "Insufficient minted");
        investorInvested[_beneficiary][uint8(FundRaiseType.ETH)] = investorInvested[_beneficiary][uint8(FundRaiseType.ETH)].add(spentValue);
        fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(spentValue);
        wallet.transfer(spentValue);
        msg.sender.transfer(msg.value.sub(spentValue));
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, FundRaiseType.ETH, msg.value, spentValue, rate);
    }

    function buyWithPOLYRateLimited(address _beneficiary, uint256 _investedPOLY, uint256 _minTokens) public validPOLY {

        _buyWithTokens(_beneficiary, _investedPOLY, FundRaiseType.POLY, _minTokens, polyToken);
    }

    function buyWithUSDRateLimited(address _beneficiary, uint256 _investedSC, uint256 _minTokens, IERC20 _usdToken)
        public validSC(_usdToken)
    {

        _buyWithTokens(_beneficiary, _investedSC, FundRaiseType.SC, _minTokens, _usdToken);
    }

    function _buyWithTokens(address _beneficiary, uint256 _tokenAmount, FundRaiseType _fundRaiseType, uint256 _minTokens, IERC20 _token) internal {

        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.SC, "Invalid raise");
        uint256 initialMinted = getTokensMinted();
        uint256 rate = getRate(_fundRaiseType);
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, _tokenAmount, rate, _fundRaiseType);
        require(getTokensMinted().sub(initialMinted) >= _minTokens, "Insufficient minted");
        investorInvested[_beneficiary][uint8(_fundRaiseType)] = investorInvested[_beneficiary][uint8(_fundRaiseType)].add(spentValue);
        fundsRaised[uint8(_fundRaiseType)] = fundsRaised[uint8(_fundRaiseType)].add(spentValue);
        if(address(_token) != address(polyToken))
            stableCoinsRaised[address(_token)] = stableCoinsRaised[address(_token)].add(spentValue);
        require(_token.transferFrom(msg.sender, wallet, spentValue), "Transfer failed");
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, _fundRaiseType, _tokenAmount, spentValue, rate);
    }

    function _buyTokens(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 _rate,
        FundRaiseType _fundRaiseType
    )
        internal
        nonReentrant
        whenNotPaused
        returns(uint256 spentUSD, uint256 spentValue)
    {

        if (!allowBeneficialInvestments) {
            require(_beneficiary == msg.sender, "Beneficiary != funder");
        }

        uint256 originalUSD = DecimalMath.mul(_rate, _investmentValue);
        uint256 allowedUSD = _buyTokensChecks(_beneficiary, _investmentValue, originalUSD);

        for (uint256 i = currentTier; i < tiers.length; i++) {
            bool gotoNextTier;
            uint256 tempSpentUSD;
            if (currentTier != i)
                currentTier = i;
            if (tiers[i].mintedTotal < tiers[i].tokenTotal) {
                (tempSpentUSD, gotoNextTier) = _calculateTier(_beneficiary, i, allowedUSD.sub(spentUSD), _fundRaiseType);
                spentUSD = spentUSD.add(tempSpentUSD);
                if (!gotoNextTier)
                    break;
            }
        }

        if (spentUSD > 0) {
            if (investorInvestedUSD[_beneficiary] == 0)
                investorCount = investorCount + 1;
            investorInvestedUSD[_beneficiary] = investorInvestedUSD[_beneficiary].add(spentUSD);
            fundsRaisedUSD = fundsRaisedUSD.add(spentUSD);
        }

        spentValue = DecimalMath.div(spentUSD, _rate);
    }

    function buyTokensView(
        address _beneficiary,
        uint256 _investmentValue,
        FundRaiseType _fundRaiseType
    )
        external
        view
        returns(uint256 spentUSD, uint256 spentValue, uint256 tokensMinted)
    {

        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.SC || _fundRaiseType == FundRaiseType.ETH, "Invalid raise type");
        uint256 rate = getRate(_fundRaiseType);
        uint256 originalUSD = DecimalMath.mul(rate, _investmentValue);
        uint256 allowedUSD = _buyTokensChecks(_beneficiary, _investmentValue, originalUSD);

        for (uint256 i = currentTier; i < tiers.length; i++) {
            bool gotoNextTier;
            uint256 tempSpentUSD;
            uint256 tempTokensMinted;
            if (tiers[i].mintedTotal < tiers[i].tokenTotal) {
                (tempSpentUSD, gotoNextTier, tempTokensMinted) = _calculateTierView(i, allowedUSD.sub(spentUSD), _fundRaiseType);
                spentUSD = spentUSD.add(tempSpentUSD);
                tokensMinted = tokensMinted.add(tempTokensMinted);
                if (!gotoNextTier)
                    break;
            }
        }

        spentValue = DecimalMath.div(spentUSD, rate);
    }

    function _buyTokensChecks(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 investedUSD
    )
        internal
        view
        returns(uint256 netInvestedUSD)
    {

        require(isOpen(), "STO not open");
        require(_investmentValue > 0, "No funds were sent");

        require(investedUSD.add(investorInvestedUSD[_beneficiary]) >= minimumInvestmentUSD, "investment < minimumInvestmentUSD");
        netInvestedUSD = investedUSD;
        if (investors[_beneficiary].accredited == uint8(0)) {
            uint256 investorLimitUSD = (investors[_beneficiary].nonAccreditedLimitUSDOverride == 0) ? nonAccreditedLimitUSD : investors[_beneficiary].nonAccreditedLimitUSDOverride;
            require(investorInvestedUSD[_beneficiary] < investorLimitUSD, "Over investor limit");
            if (investedUSD.add(investorInvestedUSD[_beneficiary]) > investorLimitUSD)
                netInvestedUSD = investorLimitUSD.sub(investorInvestedUSD[_beneficiary]);
        }
    }

    function _calculateTier(
        address _beneficiary,
        uint256 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    )
        internal
        returns(uint256 spentUSD, bool gotoNextTier)
     {

        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        uint256 investedUSD = _investedUSD;
        Tier storage tierData = tiers[_tier];
        if ((_fundRaiseType == FundRaiseType.POLY) && (tierData.tokensDiscountPoly > tierData.mintedDiscountPoly)) {
            uint256 discountRemaining = tierData.tokensDiscountPoly.sub(tierData.mintedDiscountPoly);
            uint256 totalRemaining = tierData.tokenTotal.sub(tierData.mintedTotal);
            if (totalRemaining < discountRemaining)
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, totalRemaining, investedUSD, _tier);
            else
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, discountRemaining, investedUSD, _tier);
            investedUSD = investedUSD.sub(spentUSD);
            tierData.mintedDiscountPoly = tierData.mintedDiscountPoly.add(tierPurchasedTokens);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
        if (investedUSD > 0 &&
            tierData.tokenTotal.sub(tierData.mintedTotal) > 0 &&
            (_fundRaiseType != FundRaiseType.POLY || tierData.tokensDiscountPoly <= tierData.mintedDiscountPoly)
        ) {
            (tierSpentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rate, tierData.tokenTotal.sub(tierData.mintedTotal), investedUSD, _tier);
            spentUSD = spentUSD.add(tierSpentUSD);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
    }

    function _calculateTierView(
        uint256 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    )
        internal
        view
        returns(uint256 spentUSD, bool gotoNextTier, uint256 tokensMinted)
    {

        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        Tier storage tierData = tiers[_tier];
        if ((_fundRaiseType == FundRaiseType.POLY) && (tierData.tokensDiscountPoly > tierData.mintedDiscountPoly)) {
            uint256 discountRemaining = tierData.tokensDiscountPoly.sub(tierData.mintedDiscountPoly);
            uint256 totalRemaining = tierData.tokenTotal.sub(tierData.mintedTotal);
            if (totalRemaining < discountRemaining)
                (spentUSD, tokensMinted, gotoNextTier) = _purchaseTierAmount(tierData.rateDiscountPoly, totalRemaining, _investedUSD);
            else
                (spentUSD, tokensMinted, gotoNextTier) = _purchaseTierAmount(tierData.rateDiscountPoly, discountRemaining, _investedUSD);
            _investedUSD = _investedUSD.sub(spentUSD);
        }
        if (_investedUSD > 0 &&
            tierData.tokenTotal.sub(tierData.mintedTotal.add(tokensMinted)) > 0 &&
            (_fundRaiseType != FundRaiseType.POLY || tierData.tokensDiscountPoly <= tierData.mintedDiscountPoly)
        ) {
            (tierSpentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTierAmount(tierData.rate, tierData.tokenTotal.sub(tierData.mintedTotal), _investedUSD);
            spentUSD = spentUSD.add(tierSpentUSD);
            tokensMinted = tokensMinted.add(tierPurchasedTokens);
        }
    }

    function _purchaseTier(
        address _beneficiary,
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD,
        uint256 _tier
    )
        internal
        returns(uint256 spentUSD, uint256 purchasedTokens, bool gotoNextTier)
    {

        (spentUSD, purchasedTokens, gotoNextTier) = _purchaseTierAmount(_tierPrice, _tierRemaining, _investedUSD);
        if (purchasedTokens > 0) {
            require(ISecurityToken(securityToken).mint(_beneficiary, purchasedTokens), "Error in minting");
            emit TokenPurchase(msg.sender, _beneficiary, purchasedTokens, spentUSD, _tierPrice, _tier);
        }
    }

    function _purchaseTierAmount(
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD
    )
        internal
        view
        returns(uint256 spentUSD, uint256 purchasedTokens, bool gotoNextTier)
    {

        purchasedTokens = DecimalMath.div(_investedUSD, _tierPrice);
        uint256 granularity = ISecurityToken(securityToken).granularity();

        if (purchasedTokens > _tierRemaining) {
            purchasedTokens = _tierRemaining.div(granularity);
            gotoNextTier = true;
        } else {
            purchasedTokens = purchasedTokens.div(granularity);
        }

        purchasedTokens = purchasedTokens.mul(granularity);
        spentUSD = DecimalMath.mul(purchasedTokens, _tierPrice);

        if (spentUSD > _investedUSD) {
            spentUSD = _investedUSD;
        }
    }


    function isOpen() public view returns(bool) {

        if (isFinalized)
            return false;
        if (now < startTime)
            return false;
        if (now >= endTime)
            return false;
        if (capReached())
            return false;
        return true;
    }

    function capReached() public view returns (bool) {

        if (isFinalized) {
            return (finalAmountReturned == 0);
        }
        return (tiers[tiers.length - 1].mintedTotal == tiers[tiers.length - 1].tokenTotal);
    }

    function getRate(FundRaiseType _fundRaiseType) public view returns (uint256) {

        if (_fundRaiseType == FundRaiseType.ETH) {
            return IOracle(_getOracle(bytes32("ETH"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.POLY) {
            return IOracle(_getOracle(bytes32("POLY"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.SC) {
            return 1 * 10**18;
        } else {
            revert("Incorrect funding");
        }
    }

    function convertToUSD(FundRaiseType _fundRaiseType, uint256 _amount) external view returns(uint256) {

        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.mul(_amount, rate);
    }

    function convertFromUSD(FundRaiseType _fundRaiseType, uint256 _amount) external view returns(uint256) {

        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.div(_amount, rate);
    }

    function getTokensSold() public view returns (uint256) {

        if (isFinalized)
            return totalTokensSold;
        else
            return getTokensMinted();
    }

    function getTokensMinted() public view returns (uint256) {

        uint256 tokensMinted;
        for (uint256 i = 0; i < tiers.length; i++) {
            tokensMinted = tokensMinted.add(tiers[i].mintedTotal);
        }
        return tokensMinted;
    }

    function getTokensSoldFor(FundRaiseType _fundRaiseType) external view returns (uint256) {

        uint256 tokensSold;
        for (uint256 i = 0; i < tiers.length; i++) {
            tokensSold = tokensSold.add(tiers[i].minted[uint8(_fundRaiseType)]);
        }
        return tokensSold;
    }

    function getTokensMintedByTier(uint256 _tier) external view returns (uint256[]) {

        require(_tier < tiers.length, "Invalid tier");
        uint256[] memory tokensMinted = new uint256[](3);
        tokensMinted[0] = tiers[_tier].minted[uint8(FundRaiseType.ETH)];
        tokensMinted[1] = tiers[_tier].minted[uint8(FundRaiseType.POLY)];
        tokensMinted[2] = tiers[_tier].minted[uint8(FundRaiseType.SC)];
        return tokensMinted;
    }

    function getTokensSoldByTier(uint256 _tier) external view returns (uint256) {

        require(_tier < tiers.length, "Incorrect tier");
        uint256 tokensSold;
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.ETH)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.POLY)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.SC)]);
        return tokensSold;
    }

    function getNumberOfTiers() external view returns (uint256) {

        return tiers.length;
    }

    function getUsdTokens() external view returns (address[]) {

        return usdTokens;
    }

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](0);
        return allPermissions;
    }

    function getSTODetails() external view returns(uint256, uint256, uint256, uint256[], uint256[], uint256, uint256, uint256, bool[]) {

        uint256[] memory cap = new uint256[](tiers.length);
        uint256[] memory rate = new uint256[](tiers.length);
        for(uint256 i = 0; i < tiers.length; i++) {
            cap[i] = tiers[i].tokenTotal;
            rate[i] = tiers[i].rate;
        }
        bool[] memory _fundRaiseTypes = new bool[](3);
        _fundRaiseTypes[0] = fundRaiseTypes[uint8(FundRaiseType.ETH)];
        _fundRaiseTypes[1] = fundRaiseTypes[uint8(FundRaiseType.POLY)];
        _fundRaiseTypes[2] = fundRaiseTypes[uint8(FundRaiseType.SC)];
        return (
            startTime,
            endTime,
            currentTier,
            cap,
            rate,
            fundsRaisedUSD,
            investorCount,
            getTokensSold(),
            _fundRaiseTypes
        );
    }

    function getInitFunction() public pure returns (bytes4) {

        return 0xeac2f9e4;
    }

    function _getOracle(bytes32 _currency, bytes32 _denominatedCurrency) internal view returns (address) {

        return PolymathRegistry(RegistryUpdater(securityToken).polymathRegistry()).getAddress(oracleKeys[_currency][_denominatedCurrency]);
    }

}