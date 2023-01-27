pragma solidity 0.5.16;

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
pragma solidity 0.5.16;


contract Ownable {

    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller should be owner.");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: use renounce ownership instead.");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function transferAnyERC20Token(address _tokenAddress, uint256 _tokens) public onlyOwner returns (bool _success) {

        return IERC20(_tokenAddress).transfer(owner(), _tokens);
    }
}
pragma solidity 0.5.16;

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
pragma solidity 0.5.16;

interface IMorpherToken {

    function emitTransfer(address _from, address _to, uint256 _amount) external;

}
pragma solidity 0.5.16;



contract MorpherState is Ownable {

    using SafeMath for uint256;

    bool public mainChain;
    uint256 public totalSupply;
    uint256 public totalToken;
    uint256 public totalInPositions;
    uint256 public totalOnOtherChain;
    uint256 public maximumLeverage = 10**9; // Leverage precision is 1e8, maximum leverage set to 10 initially
    uint256 constant PRECISION = 10**8;
    uint256 constant DECIMALS = 18;
    uint256 constant REWARDPERIOD = 1 days;
    bool public paused = false;

    address public morpherGovernance;
    address public morpherRewards;
    address public administrator;
    address public oracleContract;
    address public sideChainOperator;
    address public morpherBridge;
    address public morpherToken;

    uint256 public rewardBasisPoints;
    uint256 public lastRewardTime;

    bytes32 public sideChainMerkleRoot;
    uint256 public sideChainMerkleRootWrittenAtTime;

    uint256 public mainChainWithdrawLimit24 = 2 * 10**25;

    mapping(address => bool) private stateAccess;
    mapping(address => bool) private transferAllowed;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    mapping(bytes32 => bool) private marketActive;

    struct position {
        uint256 lastUpdated;
        uint256 longShares;
        uint256 shortShares;
        uint256 meanEntryPrice;
        uint256 meanEntrySpread;
        uint256 meanEntryLeverage;
        uint256 liquidationPrice;
        bytes32 positionHash;
    }

    mapping(address => mapping(bytes32 => position)) private portfolio;

    struct hasExposure {
        uint256 maxMappingIndex;
        mapping(address => uint256) index;
        mapping(uint256 => address) addy;
    }

    mapping(bytes32 => hasExposure) private exposureByMarket;

    mapping (address => uint256) private tokenClaimedOnThisChain;
    mapping (address => uint256) private tokenSentToLinkedChain;
    mapping (address => uint256) private tokenSentToLinkedChainTime;
    mapping (bytes32 => bool) private positionClaimedOnMainChain;

    uint256 public lastWithdrawLimitReductionTime;
    uint256 public last24HoursAmountWithdrawn;
    uint256 public withdrawLimit24Hours;
    uint256 public inactivityPeriod = 3 days;
    uint256 public transferNonce;
    bool public fastTransfersEnabled;


    mapping(address => uint256) private lastRequestBlock;
    mapping(address => uint256) private numberOfRequests;
    uint256 public numberOfRequestsLimit;

    event StateAccessGranted(address indexed whiteList, uint256 indexed blockNumber);
    event StateAccessDenied(address indexed blackList, uint256 indexed blockNumber);

    event TransfersEnabled(address indexed whiteList);
    event TransfersDisabled(address indexed blackList);

    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Mint(address indexed recipient, uint256 amount, uint256 totalToken);
    event Burn(address indexed recipient, uint256 amount, uint256 totalToken);
    event NewTotalSupply(uint256 newTotalSupply);
    event NewTotalOnOtherChain(uint256 newTotalOnOtherChain);
    event NewTotalInPositions(uint256 newTotalOnOtherChain);
    event OperatingRewardMinted(address indexed recipient, uint256 amount);

    event RewardsChange(address indexed rewardsAddress, uint256 indexed rewardsBasisPoints);
    event LastRewardTime(uint256 indexed rewardsTime);
    event GovernanceChange(address indexed governanceAddress);
    event TokenChange(address indexed tokenAddress);
    event AdministratorChange(address indexed administratorAddress);
    event OracleChange(address indexed oracleContract);
    event MaximumLeverageChange(uint256 maxLeverage);
    event MarketActivated(bytes32 indexed activateMarket);
    event MarketDeActivated(bytes32 indexed deActivateMarket);
    event BridgeChange(address _bridgeAddress);
    event SideChainMerkleRootUpdate(bytes32 indexed sideChainMerkleRoot);
    event NewSideChainOperator(address indexed sideChainOperator);
    event NumberOfRequestsLimitUpdate(uint256 _numberOfRequests);

    event MainChainWithdrawLimitUpdate(uint256 indexed mainChainWithdrawLimit24);
    event TokenSentToLinkedChain(address _address, uint256 _token, uint256 _totalTokenSent, bytes32 indexed _tokenSentToLinkedChainHash);
    event TransferredTokenClaimed(address _address, uint256 _token);
    event LastWithdrawAt();
    event RollingWithdrawnAmountUpdated(uint256 _last24HoursAmountWithdrawn, uint256 _lastWithdrawLimitReductionTime);
    event WithdrawLimitUpdated(uint256 _amount);
    event InactivityPeriodUpdated(uint256 _periodLength);
    event FastWithdrawsDisabled();
    event NewBridgeNonce(uint256 _transferNonce);
    event Last24HoursAmountWithdrawnReset();

    event StatePaused(address administrator, bool _paused);

    event SetAllowance(address indexed sender, address indexed spender, uint256 tokens);
    event SetPosition(bytes32 indexed positionHash,
        address indexed sender,
        bytes32 indexed marketId,
        uint256 timeStamp,
        uint256 longShares,
        uint256 shortShares,
        uint256 meanEntryPrice,
        uint256 meanEntrySpread,
        uint256 meanEntryLeverage,
        uint256 liquidationPrice
    );
    event SetBalance(address indexed account, uint256 balance, bytes32 indexed balanceHash);
    event TokenTransferredToOtherChain(address indexed account, uint256 tokenTransferredToOtherChain, bytes32 indexed transferHash);

    modifier notPaused {

        require(paused == false, "MorpherState: Contract paused, aborting");
        _;
    }

    modifier onlyPlatform {

        require(stateAccess[msg.sender] == true, "MorpherState: Only Platform is allowed to execute operation.");
        _;
    }

    modifier onlyGovernance {

        require(msg.sender == getGovernance(), "MorpherState: Calling contract not the Governance Contract. Aborting.");
        _;
    }

    modifier onlyAdministrator {

        require(msg.sender == getAdministrator(), "MorpherState: Caller is not the Administrator. Aborting.");
        _;
    }

    modifier onlySideChainOperator {

        require(msg.sender == sideChainOperator, "MorpherState: Caller is not the Sidechain Operator. Aborting.");
        _;
    }

    modifier canTransfer(address sender) {

        require(getCanTransfer(sender), "MorpherState: Caller may not transfer token. Aborting.");
        _;
    }

    modifier onlyBridge {

        require(msg.sender == getMorpherBridge(), "MorpherState: Caller is not the Bridge. Aborting.");
        _;
    }

    modifier onlyMainChain {

        require(mainChain == true, "MorpherState: Can only be called on mainchain.");
        _;
    }

    modifier onlySideChain {

        require(mainChain == false, "MorpherState: Can only be called on mainchain.");
        _;
    }

    constructor(bool _mainChain, address _sideChainOperator, address _morpherTreasury) public {
        mainChain = _mainChain; // true for Ethereum, false for Morpher PoA sidechain
        setLastRewardTime(now);
        uint256 _sideChainMint = 575000000 * 10**(DECIMALS);
        uint256 _mainChainMint = 425000000 * 10**(DECIMALS);
        
        administrator = owner(); //first set the owner as administrator
        morpherGovernance = owner(); //first set the owner as governance
        
        grantAccess(owner());
        setSideChainOperator(owner());
        if (mainChain == false) { // Create token only on sidechain
            balances[owner()] = _sideChainMint; // Create airdrop and team token on sidechain
            totalToken = _sideChainMint;
            emit Mint(owner(), balanceOf(owner()), _sideChainMint);
            setRewardBasisPoints(0); // Reward is minted on mainchain
            setRewardAddress(address(0));
            setTotalOnOtherChain(_mainChainMint);
        } else {
            balances[owner()] = _mainChainMint; // Create treasury and investor token on mainchain
            totalToken = _mainChainMint;
            emit Mint(owner(), balanceOf(owner()), _mainChainMint);
            setRewardBasisPoints(15000); // 15000 / PRECISION = 0.00015
            setRewardAddress(_morpherTreasury);
            setTotalOnOtherChain(_sideChainMint);
        }
        fastTransfersEnabled = true;
        setNumberOfRequestsLimit(3);
        setMainChainWithdrawLimit(totalSupply / 50);
        setSideChainOperator(_sideChainOperator);
        denyAccess(owner());
    }


    function getMaxMappingIndex(bytes32 _marketId) public view returns(uint256 _maxMappingIndex) {

        return exposureByMarket[_marketId].maxMappingIndex;
    }

    function getExposureMappingIndex(bytes32 _marketId, address _address) public view returns(uint256 _mappingIndex) {

        return exposureByMarket[_marketId].index[_address];
    }

    function getExposureMappingAddress(bytes32 _marketId, uint256 _mappingIndex) public view returns(address _address) {

        return exposureByMarket[_marketId].addy[_mappingIndex];
    }

    function setMaxMappingIndex(bytes32 _marketId, uint256 _maxMappingIndex) public onlyPlatform {

        exposureByMarket[_marketId].maxMappingIndex = _maxMappingIndex;
    }

    function setExposureMapping(bytes32 _marketId, address _address, uint256 _index) public onlyPlatform  {

        setExposureMappingIndex(_marketId, _address, _index);
        setExposureMappingAddress(_marketId, _address, _index);
    }

    function setExposureMappingIndex(bytes32 _marketId, address _address, uint256 _index) public onlyPlatform {

        exposureByMarket[_marketId].index[_address] = _index;
    }

    function setExposureMappingAddress(bytes32 _marketId, address _address, uint256 _index) public onlyPlatform {

        exposureByMarket[_marketId].addy[_index] = _address;
    }

    function setTokenClaimedOnThisChain(address _address, uint256 _token) public onlyBridge {

        tokenClaimedOnThisChain[_address] = _token;
        emit TransferredTokenClaimed(_address, _token);
    }

    function getTokenClaimedOnThisChain(address _address) public view returns (uint256 _token) {

        return tokenClaimedOnThisChain[_address];
    }

    function setTokenSentToLinkedChain(address _address, uint256 _token) public onlyBridge {

        tokenSentToLinkedChain[_address] = _token;
        tokenSentToLinkedChainTime[_address] = now;
        emit TokenSentToLinkedChain(_address, _token, tokenSentToLinkedChain[_address], getBalanceHash(_address, tokenSentToLinkedChain[_address]));
    }

    function getTokenSentToLinkedChain(address _address) public view returns (uint256 _token) {

        return tokenSentToLinkedChain[_address];
    }

    function getTokenSentToLinkedChainTime(address _address) public view returns (uint256 _timeStamp) {

        return tokenSentToLinkedChainTime[_address];
    }

    function add24HoursWithdrawn(uint256 _amount) public onlyBridge {

        last24HoursAmountWithdrawn = last24HoursAmountWithdrawn.add(_amount);
        emit RollingWithdrawnAmountUpdated(last24HoursAmountWithdrawn, lastWithdrawLimitReductionTime);
    }

    function update24HoursWithdrawLimit(uint256 _amount) public onlyBridge {

        if (last24HoursAmountWithdrawn > _amount) {
            last24HoursAmountWithdrawn = last24HoursAmountWithdrawn.sub(_amount);
        } else {
            last24HoursAmountWithdrawn = 0;
        }
        lastWithdrawLimitReductionTime = now;
        emit RollingWithdrawnAmountUpdated(last24HoursAmountWithdrawn, lastWithdrawLimitReductionTime);
    }

    function set24HourWithdrawLimit(uint256 _limit) public onlyBridge {

        withdrawLimit24Hours = _limit;
        emit WithdrawLimitUpdated(_limit);
    }

    function resetLast24HoursAmountWithdrawn() public onlyBridge {

        last24HoursAmountWithdrawn = 0;
        emit Last24HoursAmountWithdrawnReset();
    }

    function setInactivityPeriod(uint256 _periodLength) public onlyBridge {

        inactivityPeriod = _periodLength;
        emit InactivityPeriodUpdated(_periodLength);
    }

    function getBridgeNonce() public onlyBridge returns (uint256 _nonce) {

        transferNonce++;
        emit NewBridgeNonce(transferNonce);
        return transferNonce;
    }

    function disableFastWithdraws() public onlyBridge {

        fastTransfersEnabled = false;
        emit FastWithdrawsDisabled();
    }

    function setPositionClaimedOnMainChain(bytes32 _positionHash) public onlyBridge {

        positionClaimedOnMainChain[_positionHash] = true;
    }

    function getPositionClaimedOnMainChain(bytes32 _positionHash) public view returns (bool _alreadyClaimed) {

        return positionClaimedOnMainChain[_positionHash];
    }


    function setLastRequestBlock(address _address) public onlyPlatform {

        lastRequestBlock[_address] = block.number;
    }

    function getLastRequestBlock(address _address) public view returns(uint256 _lastRequestBlock) {

        return lastRequestBlock[_address];
    }

    function setNumberOfRequests(address _address, uint256 _numberOfRequests) public onlyPlatform {

        numberOfRequests[_address] = _numberOfRequests;
    }

    function increaseNumberOfRequests(address _address) public onlyPlatform{

        numberOfRequests[_address]++;
    }

    function getNumberOfRequests(address _address) public view returns(uint256 _numberOfRequests) {

        return numberOfRequests[_address];
    }

    function setNumberOfRequestsLimit(uint256 _numberOfRequestsLimit) public onlyPlatform {

        numberOfRequestsLimit = _numberOfRequestsLimit;
        emit NumberOfRequestsLimitUpdate(_numberOfRequestsLimit);
    }

    function getNumberOfRequestsLimit() public view returns (uint256 _numberOfRequestsLimit) {

        return numberOfRequestsLimit;
    }

    function setMainChainWithdrawLimit(uint256 _mainChainWithdrawLimit24) public onlyGovernance {

        mainChainWithdrawLimit24 = _mainChainWithdrawLimit24;
        emit MainChainWithdrawLimitUpdate(_mainChainWithdrawLimit24);
    }

    function getMainChainWithdrawLimit() public view returns (uint256 _mainChainWithdrawLimit24) {

        return mainChainWithdrawLimit24;
    }


    function grantAccess(address _address) public onlyAdministrator {

        stateAccess[_address] = true;
        emit StateAccessGranted(_address, block.number);
    }

    function denyAccess(address _address) public onlyAdministrator {

        stateAccess[_address] = false;
        emit StateAccessDenied(_address, block.number);
    }

    function getStateAccess(address _address) public view returns(bool _hasAccess) {

        return stateAccess[_address];
    }


    function enableTransfers(address _address) public onlyAdministrator {

        transferAllowed[_address] = true;
        emit TransfersEnabled(_address);
    }

    function disableTransfers(address _address) public onlyAdministrator {

        transferAllowed[_address] = false;
        emit TransfersDisabled(_address);
    }

    function getCanTransfer(address _address) public view returns(bool _hasAccess) {

        return mainChain || transferAllowed[_address];
    }


    function transfer(address _from, address _to, uint256 _token) public onlyPlatform notPaused canTransfer(_from) {

        require(balances[_from] >= _token, "MorpherState: Not enough token.");
        balances[_from] = balances[_from].sub(_token);
        balances[_to] = balances[_to].add(_token);
        IMorpherToken(morpherToken).emitTransfer(_from, _to, _token);
        emit Transfer(_from, _to, _token);
        emit SetBalance(_from, balances[_from], getBalanceHash(_from, balances[_from]));
        emit SetBalance(_to, balances[_to], getBalanceHash(_to, balances[_to]));
    }

    function mint(address _address, uint256 _token) public onlyPlatform notPaused {

        balances[_address] = balances[_address].add(_token);
        totalToken = totalToken.add(_token);
        updateTotalSupply();
        IMorpherToken(morpherToken).emitTransfer(address(0), _address, _token);
        emit Mint(_address, _token, totalToken);
        emit SetBalance(_address, balances[_address], getBalanceHash(_address, balances[_address]));
    }

    function burn(address _address, uint256 _token) public onlyPlatform notPaused {

        require(balances[_address] >= _token, "MorpherState: Not enough token.");
        balances[_address] = balances[_address].sub(_token);
        totalToken = totalToken.sub(_token);
        updateTotalSupply();
        IMorpherToken(morpherToken).emitTransfer(_address, address(0), _token);
        emit Burn(_address, _token, totalToken);
        emit SetBalance(_address, balances[_address], getBalanceHash(_address, balances[_address]));
    }

    function updateTotalSupply() private {

        totalSupply = totalToken.add(totalInPositions).add(totalOnOtherChain);
        emit NewTotalSupply(totalSupply);
    }

    function setTotalInPositions(uint256 _totalInPositions) public onlyAdministrator {

        totalInPositions = _totalInPositions;
        updateTotalSupply();
        emit NewTotalInPositions(_totalInPositions);
    }

    function setTotalOnOtherChain(uint256 _newTotalOnOtherChain) public onlySideChainOperator {

        totalOnOtherChain = _newTotalOnOtherChain;
        updateTotalSupply();
        emit NewTotalOnOtherChain(_newTotalOnOtherChain);
    }

    function balanceOf(address _tokenOwner) public view returns (uint256 balance) {

        return balances[_tokenOwner];
    }

    function setAllowance(address _from, address _spender, uint256 _tokens) public onlyPlatform {

        allowed[_from][_spender] = _tokens;
        emit SetAllowance(_from, _spender, _tokens);
    }

    function getAllowance(address _tokenOwner, address spender) public view returns (uint256 remaining) {

        return allowed[_tokenOwner][spender];
    }


    function setGovernanceContract(address _newGovernanceContractAddress) public onlyGovernance {

        morpherGovernance = _newGovernanceContractAddress;
        emit GovernanceChange(_newGovernanceContractAddress);
    }

    function getGovernance() public view returns (address _governanceContract) {

        return morpherGovernance;
    }

    function setMorpherBridge(address _newBridge) public onlyGovernance {

        morpherBridge = _newBridge;
        emit BridgeChange(_newBridge);
    }

    function getMorpherBridge() public view returns (address _currentBridge) {

        return morpherBridge;
    }

    function setOracleContract(address _newOracleContract) public onlyGovernance {

        oracleContract = _newOracleContract;
        emit OracleChange(_newOracleContract);
    }

    function getOracleContract() public view returns(address) {

        return oracleContract;
    }

    function setTokenContract(address _newTokenContract) public onlyGovernance {

        morpherToken = _newTokenContract;
        emit TokenChange(_newTokenContract);
    }

    function getTokenContract() public view returns(address) {

        return morpherToken;
    }

    function setAdministrator(address _newAdministrator) public onlyGovernance {

        administrator = _newAdministrator;
        emit AdministratorChange(_newAdministrator);
    }

    function getAdministrator() public view returns(address) {

        return administrator;
    }


    function setRewardAddress(address _newRewardsAddress) public onlyGovernance {

        morpherRewards = _newRewardsAddress;
        emit RewardsChange(_newRewardsAddress, rewardBasisPoints);
    }

    function setRewardBasisPoints(uint256 _newRewardBasisPoints) public onlyGovernance {

        if (mainChain == true) {
            require(_newRewardBasisPoints <= 15000, "MorpherState: Reward basis points need to be less or equal to 15000.");
        } else {
            require(_newRewardBasisPoints == 0, "MorpherState: Reward basis points can only be set on Ethereum.");
        }
        rewardBasisPoints = _newRewardBasisPoints;
        emit RewardsChange(morpherRewards, _newRewardBasisPoints);
    }

    function setLastRewardTime(uint256 _lastRewardTime) private {

        lastRewardTime = _lastRewardTime;
        emit LastRewardTime(_lastRewardTime);
    }


    function activateMarket(bytes32 _activateMarket) public onlyAdministrator {

        marketActive[_activateMarket] = true;
        emit MarketActivated(_activateMarket);
    }

    function deActivateMarket(bytes32 _deActivateMarket) public onlyAdministrator {

        marketActive[_deActivateMarket] = false;
        emit MarketDeActivated(_deActivateMarket);
    }

    function getMarketActive(bytes32 _marketId) public view returns(bool _active) {

        return marketActive[_marketId];
    }

    function setMaximumLeverage(uint256 _newMaximumLeverage) public onlyAdministrator {

        require(_newMaximumLeverage > PRECISION, "MorpherState: Leverage precision is 1e8");
        maximumLeverage = _newMaximumLeverage;
        emit MaximumLeverageChange(_newMaximumLeverage);
    }

    function getMaximumLeverage() public view returns(uint256 _maxLeverage) {

        return maximumLeverage;
    }

    function pauseState() public onlyAdministrator {

        paused = true;
        emit StatePaused(msg.sender, true);
    }

    function unPauseState() public onlyAdministrator {

        paused = false;
        emit StatePaused(msg.sender, false);
    }


    function setSideChainMerkleRoot(bytes32 _sideChainMerkleRoot) public onlyBridge {

        sideChainMerkleRoot = _sideChainMerkleRoot;
        sideChainMerkleRootWrittenAtTime = now;
        payOperatingReward();
        emit SideChainMerkleRootUpdate(_sideChainMerkleRoot);
    }

    function getSideChainMerkleRoot() public view returns(bytes32 _sideChainMerkleRoot) {

        return sideChainMerkleRoot;
    }

    function setSideChainOperator(address _address) public onlyAdministrator {

        sideChainOperator = _address;
        emit NewSideChainOperator(_address);
    }

    function getSideChainOperator() public view returns (address _address) {

        return sideChainOperator;
    }

    function getSideChainMerkleRootWrittenAtTime() public view returns(uint256 _sideChainMerkleRoot) {

        return sideChainMerkleRootWrittenAtTime;
    }


    function setPosition(
        address _address,
        bytes32 _marketId,
        uint256 _timeStamp,
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    ) public onlyPlatform {

        portfolio[_address][_marketId].lastUpdated = _timeStamp;
        portfolio[_address][_marketId].longShares = _longShares;
        portfolio[_address][_marketId].shortShares = _shortShares;
        portfolio[_address][_marketId].meanEntryPrice = _meanEntryPrice;
        portfolio[_address][_marketId].meanEntrySpread = _meanEntrySpread;
        portfolio[_address][_marketId].meanEntryLeverage = _meanEntryLeverage;
        portfolio[_address][_marketId].liquidationPrice = _liquidationPrice;
        portfolio[_address][_marketId].positionHash = getPositionHash(
            _address,
            _marketId,
            _timeStamp,
            _longShares,
            _shortShares,
            _meanEntryPrice,
            _meanEntrySpread,
            _meanEntryLeverage,
            _liquidationPrice
        );
        if (_longShares > 0 || _shortShares > 0) {
            addExposureByMarket(_marketId, _address);
        } else {
            deleteExposureByMarket(_marketId, _address);
        }
        emit SetPosition(
            portfolio[_address][_marketId].positionHash,
            _address,
            _marketId,
            _timeStamp,
            _longShares,
            _shortShares,
            _meanEntryPrice,
            _meanEntrySpread,
            _meanEntryLeverage,
            _liquidationPrice
        );
    }

    function getPosition(
        address _address,
        bytes32 _marketId
    ) public view returns (
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    ) {

        return(
        portfolio[_address][_marketId].longShares,
        portfolio[_address][_marketId].shortShares,
        portfolio[_address][_marketId].meanEntryPrice,
        portfolio[_address][_marketId].meanEntrySpread,
        portfolio[_address][_marketId].meanEntryLeverage,
        portfolio[_address][_marketId].liquidationPrice
        );
    }

    function getPositionHash(
        address _address,
        bytes32 _marketId,
        uint256 _timeStamp,
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    ) public pure returns (bytes32 _hash) {

        return keccak256(
            abi.encodePacked(
                _address,
                _marketId,
                _timeStamp,
                _longShares,
                _shortShares,
                _meanEntryPrice,
                _meanEntrySpread,
                _meanEntryLeverage,
                _liquidationPrice
            )
        );
    }

    function getBalanceHash(address _address, uint256 _balance) public pure returns (bytes32 _hash) {

        return keccak256(abi.encodePacked(_address, _balance));
    }

    function getLastUpdated(address _address, bytes32 _marketId) public view returns (uint256 _lastUpdated) {

        return(portfolio[_address][_marketId].lastUpdated);
    }

    function getLongShares(address _address, bytes32 _marketId) public view returns (uint256 _longShares) {

        return(portfolio[_address][_marketId].longShares);
    }

    function getShortShares(address _address, bytes32 _marketId) public view returns (uint256 _shortShares) {

        return(portfolio[_address][_marketId].shortShares);
    }

    function getMeanEntryPrice(address _address, bytes32 _marketId) public view returns (uint256 _meanEntryPrice) {

        return(portfolio[_address][_marketId].meanEntryPrice);
    }

    function getMeanEntrySpread(address _address, bytes32 _marketId) public view returns (uint256 _meanEntrySpread) {

        return(portfolio[_address][_marketId].meanEntrySpread);
    }

    function getMeanEntryLeverage(address _address, bytes32 _marketId) public view returns (uint256 _meanEntryLeverage) {

        return(portfolio[_address][_marketId].meanEntryLeverage);
    }

    function getLiquidationPrice(address _address, bytes32 _marketId) public view returns (uint256 _liquidationPrice) {

        return(portfolio[_address][_marketId].liquidationPrice);
    }

    function addExposureByMarket(bytes32 _symbol, address _address) private {

        uint256 _myExposureIndex = getExposureMappingIndex(_symbol, _address);
        if (_myExposureIndex == 0) {
            uint256 _maxMappingIndex = getMaxMappingIndex(_symbol).add(1);
            setMaxMappingIndex(_symbol, _maxMappingIndex);
            setExposureMapping(_symbol, _address, _maxMappingIndex);
        }
    }

    function deleteExposureByMarket(bytes32 _symbol, address _address) private {

        uint256 _myExposureIndex = getExposureMappingIndex(_symbol, _address);
        uint256 _lastIndex = getMaxMappingIndex(_symbol);
        address _lastAddress = getExposureMappingAddress(_symbol, _lastIndex);
        if (_myExposureIndex > 0) {
            if (_myExposureIndex < _lastIndex) {
                setExposureMappingAddress(_symbol, _lastAddress, _myExposureIndex);
                setExposureMappingIndex(_symbol, _lastAddress, _myExposureIndex);
            }
            setExposureMappingAddress(_symbol, address(0), _lastIndex);
            setExposureMappingIndex(_symbol, _address, 0);
            if (_lastIndex > 0) {
                setMaxMappingIndex(_symbol, _lastIndex.sub(1));
            }
        }
    }


    function payOperatingReward() public onlyMainChain {

        if (now > lastRewardTime.add(REWARDPERIOD)) {
            uint256 _reward = totalSupply.mul(rewardBasisPoints).div(PRECISION);
            setLastRewardTime(lastRewardTime.add(REWARDPERIOD));
            mint(morpherRewards, _reward);
            emit OperatingRewardMinted(morpherRewards, _reward);
        }
    }
}
pragma solidity 0.5.16;
contract IMorpherStaking {

    
    function lastReward() public view returns (uint256);


    function totalShares() public view returns (uint256);


    function interestRate() public view returns (uint256);


    function lockupPeriod() public view returns (uint256);

    
    function minimumStake() public view returns (uint256);


    function stakingAdmin() public view returns (address);


    function updatePoolShareValue() public returns (uint256 _newPoolShareValue) ;


    function stake(uint256 _amount) public returns (uint256 _poolShares);


    function unStake(uint256 _numOfShares) public returns (uint256 _amount);


}
pragma solidity 0.5.16;


contract MorpherMintingLimiter {

    using SafeMath for uint256; 

    uint256 public mintingLimit;
    uint256 public timeLockingPeriod;

    mapping(address => uint256) public escrowedTokens;
    mapping(address => uint256) public lockedUntil;

    address tradeEngineAddress; 
    MorpherState state;

    event MintingEscrowed(address _user, uint256 _tokenAmount);
    event EscrowReleased(address _user, uint256 _tokenAmount);
    event MintingDenied(address _user, uint256 _tokenAmount);
    event MintingLimitUpdated(uint256 _mintingLimitOld, uint256 _mintingLimitNew);
    event TimeLockPeriodUpdated(uint256 _timeLockPeriodOld, uint256 _timeLockPeriodNew);
    event TradeEngineAddressSet(address _tradeEngineAddress);

    modifier onlyTradeEngine() {

        require(msg.sender == tradeEngineAddress, "MorpherMintingLimiter: Only Trade Engine is allowed to call this function");
        _;
    }

    modifier onlyAdministrator() {

        require(msg.sender == state.getAdministrator(), "MorpherMintingLimiter: Only Administrator can call this function");
        _;
    }

    constructor(address _stateAddress, uint256 _mintingLimit, uint256 _timeLockingPeriodInSeconds) public {
        state = MorpherState(_stateAddress);
        mintingLimit = _mintingLimit;
        timeLockingPeriod = _timeLockingPeriodInSeconds;
    }

    function setTradeEngineAddress(address _tradeEngineAddress) public onlyAdministrator {

        emit TradeEngineAddressSet(_tradeEngineAddress);
        tradeEngineAddress = _tradeEngineAddress;
    }
    

    function setMintingLimit(uint256 _newMintingLimit) public onlyAdministrator {

        emit MintingLimitUpdated(mintingLimit, _newMintingLimit);
        mintingLimit = _newMintingLimit;
    }

    function setTimeLockingPeriod(uint256 _newTimeLockingPeriodInSeconds) public onlyAdministrator {

        emit TimeLockPeriodUpdated(timeLockingPeriod, _newTimeLockingPeriodInSeconds);
        timeLockingPeriod = _newTimeLockingPeriodInSeconds;
    }

    function mint(address _user, uint256 _tokenAmount) public onlyTradeEngine {

        if(mintingLimit == 0 || _tokenAmount <= mintingLimit) {
            state.mint(_user, _tokenAmount);
        } else {
            escrowedTokens[_user] = escrowedTokens[_user].add(_tokenAmount);
            lockedUntil[_user] = block.timestamp + timeLockingPeriod;
            emit MintingEscrowed(_user, _tokenAmount);
        }
    }

    function delayedMint(address _user) public {

        require(lockedUntil[_user] <= block.timestamp, "MorpherMintingLimiter: Funds are still time locked");
        uint256 sendAmount = escrowedTokens[_user];
        escrowedTokens[_user] = 0;
        state.mint(_user, sendAmount);
        emit EscrowReleased(_user, sendAmount);
    }

    function adminApprovedMint(address _user, uint256 _tokenAmount) public onlyAdministrator {

        escrowedTokens[_user] = escrowedTokens[_user].sub(_tokenAmount);
        state.mint(_user, _tokenAmount);
        emit EscrowReleased(_user, _tokenAmount);
    }

    function adminDisapproveMint(address _user, uint256 _tokenAmount) public onlyAdministrator {

        escrowedTokens[_user] = escrowedTokens[_user].sub(_tokenAmount);
        emit MintingDenied(_user, _tokenAmount);
    }
}pragma solidity 0.5.16;



contract MorpherTradeEngine is Ownable {

    MorpherState state;
    IMorpherStaking staking;
    MorpherMintingLimiter mintingLimiter;
    using SafeMath for uint256;

    uint256 constant PRECISION = 10**8;
    uint256 public orderNonce;
    bytes32 public lastOrderId;
    uint256 public deployedTimeStamp;

    address public escrowOpenOrderAddress = 0x1111111111111111111111111111111111111111;
    bool public escrowOpenOrderEnabled;


    address public closedMarketPriceLock = 0x0000000000000000000000000000000000000001;


    struct order {
        address userId;
        bytes32 marketId;
        uint256 closeSharesAmount;
        uint256 openMPHTokenAmount;
        bool tradeDirection; // true = long, false = short
        uint256 liquidationTimestamp;
        uint256 marketPrice;
        uint256 marketSpread;
        uint256 orderLeverage;
        uint256 timeStamp;
        uint256 longSharesOrder;
        uint256 shortSharesOrder;
        uint256 balanceDown;
        uint256 balanceUp;
        uint256 newLongShares;
        uint256 newShortShares;
        uint256 newMeanEntryPrice;
        uint256 newMeanEntrySpread;
        uint256 newMeanEntryLeverage;
        uint256 newLiquidationPrice;
        uint256 orderEscrowAmount;
    }

    mapping(bytes32 => order) private orders;


    event PositionLiquidated(
        address indexed _address,
        bytes32 indexed _marketId,
        bool _longPosition,
        uint256 _timeStamp,
        uint256 _marketPrice,
        uint256 _marketSpread
    );

    event OrderCancelled(
        bytes32 indexed _orderId,
        address indexed _address
    );

    event OrderIdRequested(
        bytes32 _orderId,
        address indexed _address,
        bytes32 indexed _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage
    );

    event OrderProcessed(
        bytes32 _orderId,
        uint256 _marketPrice,
        uint256 _marketSpread,
        uint256 _liquidationTimestamp,
        uint256 _timeStamp,
        uint256 _newLongShares,
        uint256 _newShortShares,
        uint256 _newAverageEntry,
        uint256 _newAverageSpread,
        uint256 _newAverageLeverage,
        uint256 _liquidationPrice
    );

    event PositionUpdated(
        address _userId,
        bytes32 _marketId,
        uint256 _timeStamp,
        uint256 _newLongShares,
        uint256 _newShortShares,
        uint256 _newMeanEntryPrice,
        uint256 _newMeanEntrySpread,
        uint256 _newMeanEntryLeverage,
        uint256 _newLiquidationPrice,
        uint256 _mint,
        uint256 _burn
    );

    event LinkState(address _address);
    event LinkStaking(address _stakingAddress);
    event LinkMintingLimiter(address _mintingLimiterAddress);

    
    event LockedPriceForClosingPositions(bytes32 _marketId, uint256 _price);


    constructor(address _stateAddress, address _coldStorageOwnerAddress, address _stakingContractAddress, bool _escrowOpenOrderEnabled, uint256 _deployedTimestampOverride, address _mintingLimiterAddress) public {
        setMorpherState(_stateAddress);
        setMorpherStaking(_stakingContractAddress);
        setMorpherMintingLimiter(_mintingLimiterAddress);
        transferOwnership(_coldStorageOwnerAddress);
        escrowOpenOrderEnabled = _escrowOpenOrderEnabled;
        deployedTimeStamp = _deployedTimestampOverride > 0 ? _deployedTimestampOverride : block.timestamp;
    }

    modifier onlyOracle {

        require(msg.sender == state.getOracleContract(), "MorpherTradeEngine: function can only be called by Oracle Contract.");
        _;
    }

    modifier onlyAdministrator {

        require(msg.sender == getAdministrator(), "MorpherTradeEngine: function can only be called by the Administrator.");
        _;
    }


    function setMorpherState(address _stateAddress) public onlyOwner {

        state = MorpherState(_stateAddress);
        emit LinkState(_stateAddress);
    }

    function setMorpherStaking(address _stakingAddress) public onlyOwner {

        staking = IMorpherStaking(_stakingAddress);
        emit LinkStaking(_stakingAddress);
    }

    function setMorpherMintingLimiter(address _mintingLimiterAddress) public onlyOwner {

        mintingLimiter = MorpherMintingLimiter(_mintingLimiterAddress);
        emit LinkMintingLimiter(_mintingLimiterAddress);
    }

    function getAdministrator() public view returns(address _administrator) {

        return state.getAdministrator();
    }

    function setEscrowOpenOrderEnabled(bool _isEnabled) public onlyOwner {

        escrowOpenOrderEnabled = _isEnabled;
    }
    
    function paybackEscrow(bytes32 _orderId) private {

        if(orders[_orderId].orderEscrowAmount > 0) {
            uint256 paybackAmount = orders[_orderId].orderEscrowAmount;
            orders[_orderId].orderEscrowAmount = 0;
            state.transfer(escrowOpenOrderAddress, orders[_orderId].userId, paybackAmount);
        }
    }

    function buildupEscrow(bytes32 _orderId, uint256 _amountInMPH) private {

        if(escrowOpenOrderEnabled && _amountInMPH > 0) {
            state.transfer(orders[_orderId].userId, escrowOpenOrderAddress, _amountInMPH);
            orders[_orderId].orderEscrowAmount = _amountInMPH;
        }
    }


    function validateClosedMarketOrderConditions(address _address, bytes32 _marketId, uint256 _closeSharesAmount, uint256 _openMPHTokenAmount, bool _tradeDirection ) internal view {

        if(_openMPHTokenAmount > 0) {
            require(state.getMarketActive(_marketId) == true, "MorpherTradeEngine: market unknown or currently not enabled for trading.");
        } else {
            if(state.getMarketActive(_marketId) == false) {
                require(getDeactivatedMarketPrice(_marketId) > 0, "MorpherTradeEngine: Can't close a position, market not active and closing price not locked");
                if(_tradeDirection) {
                    require(_closeSharesAmount == state.getShortShares(_address, _marketId), "MorpherTradeEngine: Deactivated market order needs all shares to be closed");
                } else {
                    require(_closeSharesAmount == state.getLongShares(_address, _marketId), "MorpherTradeEngine: Deactivated market order needs all shares to be closed");
                }
            }
        }
    }

    function validateClosedMarketOrder(bytes32 _orderId) internal view {

         validateClosedMarketOrderConditions(orders[_orderId].userId, orders[_orderId].marketId, orders[_orderId].closeSharesAmount, orders[_orderId].openMPHTokenAmount, orders[_orderId].tradeDirection);
    }


    function requestOrderId(
        address _address,
        bytes32 _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage
        ) public onlyOracle returns (bytes32 _orderId) {

            
        require(_orderLeverage >= PRECISION, "MorpherTradeEngine: leverage too small. Leverage precision is 1e8");
        require(_orderLeverage <= state.getMaximumLeverage(), "MorpherTradeEngine: leverage exceeds maximum allowed leverage.");

        validateClosedMarketOrderConditions(_address, _marketId, _closeSharesAmount, _openMPHTokenAmount, _tradeDirection);

        require(state.getNumberOfRequests(_address) <= state.getNumberOfRequestsLimit() ||
            state.getLastRequestBlock(_address) < block.number,
            "MorpherTradeEngine: request exceeded maximum permitted requests per block."
        );

        if(_openMPHTokenAmount > 0) {
            if(_tradeDirection) {
                require(_closeSharesAmount == state.getShortShares(_address, _marketId), "MorpherTradeEngine: Can't partially close a position and open another one in opposite direction");
            } else {
                require(_closeSharesAmount == state.getLongShares(_address, _marketId), "MorpherTradeEngine: Can't partially close a position and open another one in opposite direction");
            }
        }

        state.setLastRequestBlock(_address);
        state.increaseNumberOfRequests(_address);
        orderNonce++;
        _orderId = keccak256(
            abi.encodePacked(
                _address,
                block.number,
                _marketId,
                _closeSharesAmount,
                _openMPHTokenAmount,
                _tradeDirection,
                _orderLeverage,
                orderNonce
                )
            );
        lastOrderId = _orderId;
        orders[_orderId].userId = _address;
        orders[_orderId].marketId = _marketId;
        orders[_orderId].closeSharesAmount = _closeSharesAmount;
        orders[_orderId].openMPHTokenAmount = _openMPHTokenAmount;
        orders[_orderId].tradeDirection = _tradeDirection;
        orders[_orderId].orderLeverage = _orderLeverage;
        emit OrderIdRequested(
            _orderId,
            _address,
            _marketId,
            _closeSharesAmount,
            _openMPHTokenAmount,
            _tradeDirection,
            _orderLeverage
        );

        buildupEscrow(_orderId, _openMPHTokenAmount);

        return _orderId;
    }


    function getOrder(bytes32 _orderId) public view returns (
        address _userId,
        bytes32 _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        uint256 _marketPrice,
        uint256 _marketSpread,
        uint256 _orderLeverage
        ) {

        return(
            orders[_orderId].userId,
            orders[_orderId].marketId,
            orders[_orderId].closeSharesAmount,
            orders[_orderId].openMPHTokenAmount,
            orders[_orderId].marketPrice,
            orders[_orderId].marketSpread,
            orders[_orderId].orderLeverage
            );
    }

    function getPosition(address _address, bytes32 _marketId) public view returns (
        uint256 _positionLongShares,
        uint256 _positionShortShares,
        uint256 _positionAveragePrice,
        uint256 _positionAverageSpread,
        uint256 _positionAverageLeverage,
        uint256 _liquidationPrice
        ) {

        return(
            state.getLongShares(_address, _marketId),
            state.getShortShares(_address, _marketId),
            state.getMeanEntryPrice(_address,_marketId),
            state.getMeanEntrySpread(_address,_marketId),
            state.getMeanEntryLeverage(_address,_marketId),
            state.getLiquidationPrice(_address,_marketId)
        );
    }

    function setDeactivatedMarketPrice(bytes32 _marketId, uint256 _price) public onlyOracle {

         state.setPosition(
            closedMarketPriceLock,
            _marketId,
            now.mul(1000),
            0,
            0,
            _price,
            0,
            0,
            0
        );

        emit LockedPriceForClosingPositions(_marketId, _price);

    }

    function getDeactivatedMarketPrice(bytes32 _marketId) public view returns(uint256) {

        ( , , uint positionForeverClosingPrice, , ,) = state.getPosition(closedMarketPriceLock, _marketId);
        return positionForeverClosingPrice;
    }


    function liquidate(bytes32 _orderId) private {

        address _address = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;
        uint256 _liquidationTimestamp = orders[_orderId].liquidationTimestamp;
        if (_liquidationTimestamp > state.getLastUpdated(_address, _marketId)) {
            if (state.getLongShares(_address,_marketId) > 0) {
                state.setPosition(
                    _address,
                    _marketId,
                    orders[_orderId].timeStamp,
                    0,
                    state.getShortShares(_address, _marketId),
                    0,
                    0,
                    PRECISION,
                    0);
                emit PositionLiquidated(
                    _address,
                    _marketId,
                    true,
                    orders[_orderId].timeStamp,
                    orders[_orderId].marketPrice,
                    orders[_orderId].marketSpread
                );
            }
            if (state.getShortShares(_address,_marketId) > 0) {
                state.setPosition(
                    _address,
                    _marketId,
                    orders[_orderId].timeStamp,
                    state.getLongShares(_address, _marketId),
                    0,
                    0,
                    0,
                    PRECISION,
                    0
                );
                emit PositionLiquidated(
                    _address,
                    _marketId,
                    false,
                    orders[_orderId].timeStamp,
                    orders[_orderId].marketPrice,
                    orders[_orderId].marketSpread
                );
            }
        }
    }


    function processOrder(
        bytes32 _orderId,
        uint256 _marketPrice,
        uint256 _marketSpread,
        uint256 _liquidationTimestamp,
        uint256 _timeStampInMS
        ) public onlyOracle returns (
            uint256 _newLongShares,
            uint256 _newShortShares,
            uint256 _newAverageEntry,
            uint256 _newAverageSpread,
            uint256 _newAverageLeverage,
            uint256 _liquidationPrice
        ) {

        require(orders[_orderId].userId != address(0), "MorpherTradeEngine: unable to process, order has been deleted.");
        require(_marketPrice > 0, "MorpherTradeEngine: market priced at zero. Buy order cannot be processed.");
        require(_marketPrice >= _marketSpread, "MorpherTradeEngine: market price lower then market spread. Order cannot be processed.");
        
        orders[_orderId].marketPrice = _marketPrice;
        orders[_orderId].marketSpread = _marketSpread;
        orders[_orderId].timeStamp = _timeStampInMS;
        orders[_orderId].liquidationTimestamp = _liquidationTimestamp;
        
        if(state.getMarketActive(orders[_orderId].marketId) == false) {
            validateClosedMarketOrder(_orderId);
            orders[_orderId].marketPrice = getDeactivatedMarketPrice(orders[_orderId].marketId);
        }
        
        if (_liquidationTimestamp > state.getLastUpdated(orders[_orderId].userId, orders[_orderId].marketId)) {
            liquidate(_orderId);
        }
    

        paybackEscrow(_orderId);

        if (orders[_orderId].tradeDirection) {
            processBuyOrder(_orderId);
        } else {
            processSellOrder(_orderId);
        }

        address _address = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;
        delete orders[_orderId];
        emit OrderProcessed(
            _orderId,
            _marketPrice,
            _marketSpread,
            _liquidationTimestamp,
            _timeStampInMS,
            _newLongShares,
            _newShortShares,
            _newAverageEntry,
            _newAverageSpread,
            _newAverageLeverage,
            _liquidationPrice
        );

        return (
            state.getLongShares(_address, _marketId),
            state.getShortShares(_address, _marketId),
            state.getMeanEntryPrice(_address,_marketId),
            state.getMeanEntrySpread(_address,_marketId),
            state.getMeanEntryLeverage(_address,_marketId),
            state.getLiquidationPrice(_address,_marketId)
        );
    }

    function cancelOrder(bytes32 _orderId, address _address) public onlyOracle {

        require(_address == orders[_orderId].userId || _address == getAdministrator(), "MorpherTradeEngine: only Administrator or user can cancel an order.");
        require(orders[_orderId].userId != address(0), "MorpherTradeEngine: unable to process, order does not exist.");

        paybackEscrow(_orderId);

        delete orders[_orderId];
        emit OrderCancelled(_orderId, _address);
    }

    function shortShareValue(
        uint256 _positionAveragePrice,
        uint256 _positionAverageLeverage,
        uint256 _positionTimeStampInMs,
        uint256 _marketPrice,
        uint256 _marketSpread,
        uint256 _orderLeverage,
        bool _sell
        ) public view returns (uint256 _shareValue) {


        uint256 _averagePrice = _positionAveragePrice;
        uint256 _averageLeverage = _positionAverageLeverage;

        if (_positionAverageLeverage < PRECISION) {
            _averageLeverage = PRECISION;
        }
        if (_sell == false) {
            _averagePrice = _marketPrice;
	        _averageLeverage = _orderLeverage;
        }
        if (
            getLiquidationPrice(_averagePrice, _averageLeverage, false, _positionTimeStampInMs) <= _marketPrice
            ) {
            _shareValue = 0;
        } else {
            _shareValue = _averagePrice.mul((PRECISION.add(_averageLeverage))).div(PRECISION);
            _shareValue = _shareValue.sub(_marketPrice.mul(_averageLeverage).div(PRECISION));
            if (_sell == true) {
                _shareValue = _shareValue.sub(_marketSpread.mul(_averageLeverage).div(PRECISION));
                uint256 _marginInterest = calculateMarginInterest(_averagePrice, _averageLeverage, _positionTimeStampInMs);
                if (_marginInterest <= _shareValue) {
                    _shareValue = _shareValue.sub(_marginInterest);
                } else {
                    _shareValue = 0;
                }
            } else {
                _shareValue = _shareValue.add(_marketSpread.mul(_orderLeverage).div(PRECISION));
            }
        }
      
        return _shareValue;
    }

    function longShareValue(
        uint256 _positionAveragePrice,
        uint256 _positionAverageLeverage,
        uint256 _positionTimeStampInMs,
        uint256 _marketPrice,
        uint256 _marketSpread,
        uint256 _orderLeverage,
        bool _sell
        ) public view returns (uint256 _shareValue) {


        uint256 _averagePrice = _positionAveragePrice;
        uint256 _averageLeverage = _positionAverageLeverage;

        if (_positionAverageLeverage < PRECISION) {
            _averageLeverage = PRECISION;
        }
        if (_sell == false) {
            _averagePrice = _marketPrice;
	        _averageLeverage = _orderLeverage;
        }
        if (
            _marketPrice <= getLiquidationPrice(_averagePrice, _averageLeverage, true, _positionTimeStampInMs)
            ) {
            _shareValue = 0;
        } else {
            _shareValue = _averagePrice.mul(_averageLeverage.sub(PRECISION)).div(PRECISION);
            _shareValue = (_marketPrice.mul(_averageLeverage).div(PRECISION)).sub(_shareValue);
            if (_sell == true) {
                _shareValue = _shareValue.sub(_marketSpread.mul(_averageLeverage).div(PRECISION));
                
                uint256 _marginInterest = calculateMarginInterest(_averagePrice, _averageLeverage, _positionTimeStampInMs);
                if (_marginInterest <= _shareValue) {
                    _shareValue = _shareValue.sub(_marginInterest);
                } else {
                    _shareValue = 0;
                }
            } else {
                _shareValue = _shareValue.add(_marketSpread.mul(_orderLeverage).div(PRECISION));
            }
        }
        return _shareValue;
    }



    function calculateMarginInterest(uint256 _averagePrice, uint256 _averageLeverage, uint256 _positionTimeStampInMs) public view returns (uint256 _marginInterest) {

        if (_positionTimeStampInMs.div(1000) < deployedTimeStamp) {
            _positionTimeStampInMs = deployedTimeStamp.mul(1000);
        }
        _marginInterest = _averagePrice.mul(_averageLeverage.sub(PRECISION));
        _marginInterest = _marginInterest.mul((now.sub(_positionTimeStampInMs.div(1000)).div(86400)).add(1));
        _marginInterest = _marginInterest.mul(staking.interestRate()).div(PRECISION).div(PRECISION);
        return _marginInterest;
    }


    function processBuyOrder(bytes32 _orderId) private {

        if (orders[_orderId].closeSharesAmount > 0) {

            if (orders[_orderId].closeSharesAmount <= state.getShortShares(orders[_orderId].userId, orders[_orderId].marketId)) {
                orders[_orderId].shortSharesOrder = orders[_orderId].closeSharesAmount;
            } else {
                orders[_orderId].shortSharesOrder = state.getShortShares(orders[_orderId].userId, orders[_orderId].marketId);
            }
        }

        if(
            orders[_orderId].shortSharesOrder == state.getShortShares(orders[_orderId].userId, orders[_orderId].marketId) && 
            orders[_orderId].openMPHTokenAmount > 0
        ) {
            orders[_orderId].longSharesOrder = orders[_orderId].openMPHTokenAmount.div(
                longShareValue(
                    orders[_orderId].marketPrice,
                    orders[_orderId].orderLeverage,
                    now,
                    orders[_orderId].marketPrice,
                    orders[_orderId].marketSpread,
                    orders[_orderId].orderLeverage,
                    false
            ));
        }

        if (orders[_orderId].shortSharesOrder > 0) {
            closeShort(_orderId);
        }
        if (orders[_orderId].longSharesOrder > 0) {
            openLong(_orderId);
        }
    }


    function processSellOrder(bytes32 _orderId) private {

        if (orders[_orderId].closeSharesAmount > 0) {

            if (orders[_orderId].closeSharesAmount <= state.getLongShares(orders[_orderId].userId, orders[_orderId].marketId)) {
                orders[_orderId].longSharesOrder = orders[_orderId].closeSharesAmount;
            } else {
                orders[_orderId].longSharesOrder = state.getLongShares(orders[_orderId].userId, orders[_orderId].marketId);
            }
        }

        if(
            orders[_orderId].longSharesOrder == state.getLongShares(orders[_orderId].userId, orders[_orderId].marketId) && 
            orders[_orderId].openMPHTokenAmount > 0
        ) {
        orders[_orderId].shortSharesOrder = orders[_orderId].openMPHTokenAmount.div(
                    shortShareValue(
                        orders[_orderId].marketPrice,
                        orders[_orderId].orderLeverage,
                        now,
                        orders[_orderId].marketPrice,
                        orders[_orderId].marketSpread,
                        orders[_orderId].orderLeverage,
                        false
                ));
        }
        if (orders[_orderId].longSharesOrder > 0) {
            closeLong(_orderId);
        }
        if (orders[_orderId].shortSharesOrder > 0) {
            openShort(_orderId);
        }
    }

    function openLong(bytes32 _orderId) private {

        address _userId = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;

        uint256 _newMeanSpread;
        uint256 _newMeanLeverage;


        uint256 _factorLongShares = state.getMeanEntryLeverage(_userId, _marketId);
        if (_factorLongShares < PRECISION) {
            _factorLongShares = PRECISION;
        }
        _factorLongShares = _factorLongShares.sub(PRECISION);
        _factorLongShares = _factorLongShares.mul(state.getMeanEntryPrice(_userId, _marketId)).div(orders[_orderId].marketPrice);
        if (state.getMeanEntryLeverage(_userId, _marketId) > _factorLongShares) {
            _factorLongShares = state.getMeanEntryLeverage(_userId, _marketId).sub(_factorLongShares);
        } else {
            _factorLongShares = 0;
        }

        uint256 _adjustedLongShares = _factorLongShares.mul(state.getLongShares(_userId, _marketId)).div(PRECISION);

        _newMeanLeverage = state.getMeanEntryLeverage(_userId, _marketId).mul(_adjustedLongShares);
        _newMeanLeverage = _newMeanLeverage.add(orders[_orderId].orderLeverage.mul(orders[_orderId].longSharesOrder));
        _newMeanLeverage = _newMeanLeverage.div(_adjustedLongShares.add(orders[_orderId].longSharesOrder));

        _newMeanSpread = state.getMeanEntrySpread(_userId, _marketId).mul(state.getLongShares(_userId, _marketId));
        _newMeanSpread = _newMeanSpread.add(orders[_orderId].marketSpread.mul(orders[_orderId].longSharesOrder));
        _newMeanSpread = _newMeanSpread.div(_adjustedLongShares.add(orders[_orderId].longSharesOrder));

        orders[_orderId].balanceDown = orders[_orderId].longSharesOrder.mul(orders[_orderId].marketPrice).add(
            orders[_orderId].longSharesOrder.mul(orders[_orderId].marketSpread).mul(orders[_orderId].orderLeverage).div(PRECISION)
        );
        orders[_orderId].balanceUp = 0;
        orders[_orderId].newLongShares = _adjustedLongShares.add(orders[_orderId].longSharesOrder);
        orders[_orderId].newShortShares = state.getShortShares(_userId, _marketId);
        orders[_orderId].newMeanEntryPrice = orders[_orderId].marketPrice;
        orders[_orderId].newMeanEntrySpread = _newMeanSpread;
        orders[_orderId].newMeanEntryLeverage = _newMeanLeverage;

        setPositionInState(_orderId);
    }
     function closeLong(bytes32 _orderId) private {

        address _userId = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;
        uint256 _newLongShares  = state.getLongShares(_userId, _marketId).sub(orders[_orderId].longSharesOrder);
        uint256 _balanceUp = calculateBalanceUp(_orderId);
        uint256 _newMeanEntry;
        uint256 _newMeanSpread;
        uint256 _newMeanLeverage;

        if (orders[_orderId].longSharesOrder == state.getLongShares(_userId, _marketId)) {
            _newMeanEntry = 0;
            _newMeanSpread = 0;
            _newMeanLeverage = PRECISION;
        } else {
            _newMeanEntry = state.getMeanEntryPrice(_userId, _marketId);
	        _newMeanSpread = state.getMeanEntrySpread(_userId, _marketId);
	        _newMeanLeverage = state.getMeanEntryLeverage(_userId, _marketId);
            resetTimestampInOrderToLastUpdated(_orderId);
        }

        orders[_orderId].balanceDown = 0;
        orders[_orderId].balanceUp = _balanceUp;
        orders[_orderId].newLongShares = _newLongShares;
        orders[_orderId].newShortShares = state.getShortShares(_userId, _marketId);
        orders[_orderId].newMeanEntryPrice = _newMeanEntry;
        orders[_orderId].newMeanEntrySpread = _newMeanSpread;
        orders[_orderId].newMeanEntryLeverage = _newMeanLeverage;

        setPositionInState(_orderId);
    }

event ResetTimestampInOrder(bytes32 _orderId, uint oldTimestamp, uint newTimestamp);
function resetTimestampInOrderToLastUpdated(bytes32 _orderId) internal {

    address userId = orders[_orderId].userId;
    bytes32 marketId = orders[_orderId].marketId;
    uint lastUpdated = state.getLastUpdated(userId, marketId);
    emit ResetTimestampInOrder(_orderId, orders[_orderId].timeStamp, lastUpdated);
    orders[_orderId].timeStamp = lastUpdated;
}

function calculateBalanceUp(bytes32 _orderId) private view returns (uint256 _balanceUp) {

        address _userId = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;
        uint256 _shareValue;

        if (orders[_orderId].tradeDirection == false) { //we are selling our long shares
            _balanceUp = orders[_orderId].longSharesOrder;
            _shareValue = longShareValue(
                state.getMeanEntryPrice(_userId, _marketId),
                state.getMeanEntryLeverage(_userId, _marketId),
                state.getLastUpdated(_userId, _marketId),
                orders[_orderId].marketPrice,
                orders[_orderId].marketSpread,
                state.getMeanEntryLeverage(_userId, _marketId),
                true
            );
        } else { //we are going long, we are selling our short shares
            _balanceUp = orders[_orderId].shortSharesOrder;
            _shareValue = shortShareValue(
                state.getMeanEntryPrice(_userId, _marketId),
                state.getMeanEntryLeverage(_userId, _marketId),
                state.getLastUpdated(_userId, _marketId),
                orders[_orderId].marketPrice,
                orders[_orderId].marketSpread,
                state.getMeanEntryLeverage(_userId, _marketId),
                true
            );
        }
        return _balanceUp.mul(_shareValue); 
    }

    function closeShort(bytes32 _orderId) private {

        address _userId = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;
        uint256 _newMeanEntry;
        uint256 _newMeanSpread;
        uint256 _newMeanLeverage;
        uint256 _newShortShares = state.getShortShares(_userId, _marketId).sub(orders[_orderId].shortSharesOrder);
        uint256 _balanceUp = calculateBalanceUp(_orderId);
        
        if (orders[_orderId].shortSharesOrder == state.getShortShares(_userId, _marketId)) {
            _newMeanEntry = 0;
            _newMeanSpread = 0;
	        _newMeanLeverage = PRECISION;
        } else {
            _newMeanEntry = state.getMeanEntryPrice(_userId, _marketId);
	        _newMeanSpread = state.getMeanEntrySpread(_userId, _marketId);
	        _newMeanLeverage = state.getMeanEntryLeverage(_userId, _marketId);

            resetTimestampInOrderToLastUpdated(_orderId);
        }

        orders[_orderId].balanceDown = 0;
        orders[_orderId].balanceUp = _balanceUp;
        orders[_orderId].newLongShares = state.getLongShares(orders[_orderId].userId, orders[_orderId].marketId);
        orders[_orderId].newShortShares = _newShortShares;
        orders[_orderId].newMeanEntryPrice = _newMeanEntry;
        orders[_orderId].newMeanEntrySpread = _newMeanSpread;
        orders[_orderId].newMeanEntryLeverage = _newMeanLeverage;

        setPositionInState(_orderId);
    }

    function openShort(bytes32 _orderId) private {

        address _userId = orders[_orderId].userId;
        bytes32 _marketId = orders[_orderId].marketId;

        uint256 _newMeanSpread;
        uint256 _newMeanLeverage;

        uint256 _factorShortShares = state.getMeanEntryLeverage(_userId, _marketId);
        if (_factorShortShares < PRECISION) {
            _factorShortShares = PRECISION;
        }
        _factorShortShares = _factorShortShares.add(PRECISION);
        _factorShortShares = _factorShortShares.mul(state.getMeanEntryPrice(_userId, _marketId)).div(orders[_orderId].marketPrice);
        if (state.getMeanEntryLeverage(_userId, _marketId) < _factorShortShares) {
            _factorShortShares = _factorShortShares.sub(state.getMeanEntryLeverage(_userId, _marketId));
        } else {
            _factorShortShares = 0;
        }

        uint256 _adjustedShortShares = _factorShortShares.mul(state.getShortShares(_userId, _marketId)).div(PRECISION);

        _newMeanLeverage = state.getMeanEntryLeverage(_userId, _marketId).mul(_adjustedShortShares);
        _newMeanLeverage = _newMeanLeverage.add(orders[_orderId].orderLeverage.mul(orders[_orderId].shortSharesOrder));
        _newMeanLeverage = _newMeanLeverage.div(_adjustedShortShares.add(orders[_orderId].shortSharesOrder));

        _newMeanSpread = state.getMeanEntrySpread(_userId, _marketId).mul(state.getShortShares(_userId, _marketId));
        _newMeanSpread = _newMeanSpread.add(orders[_orderId].marketSpread.mul(orders[_orderId].shortSharesOrder));
        _newMeanSpread = _newMeanSpread.div(_adjustedShortShares.add(orders[_orderId].shortSharesOrder));

        orders[_orderId].balanceDown = orders[_orderId].shortSharesOrder.mul(orders[_orderId].marketPrice).add(
            orders[_orderId].shortSharesOrder.mul(orders[_orderId].marketSpread).mul(orders[_orderId].orderLeverage).div(PRECISION)
        );
        orders[_orderId].balanceUp = 0;
        orders[_orderId].newLongShares = state.getLongShares(_userId, _marketId);
        orders[_orderId].newShortShares = _adjustedShortShares.add(orders[_orderId].shortSharesOrder);
        orders[_orderId].newMeanEntryPrice = orders[_orderId].marketPrice;
        orders[_orderId].newMeanEntrySpread = _newMeanSpread;
        orders[_orderId].newMeanEntryLeverage = _newMeanLeverage;

        setPositionInState(_orderId);
    }

    function computeLiquidationPrice(bytes32 _orderId) public returns(uint256 _liquidationPrice) {

        orders[_orderId].newLiquidationPrice = 0;
        if (orders[_orderId].newLongShares > 0) {
            orders[_orderId].newLiquidationPrice = getLiquidationPrice(orders[_orderId].newMeanEntryPrice, orders[_orderId].newMeanEntryLeverage, true, orders[_orderId].timeStamp);
        }
        if (orders[_orderId].newShortShares > 0) {
            orders[_orderId].newLiquidationPrice = getLiquidationPrice(orders[_orderId].newMeanEntryPrice, orders[_orderId].newMeanEntryLeverage, false, orders[_orderId].timeStamp);
        }
        return orders[_orderId].newLiquidationPrice;
    }

    function getLiquidationPrice(uint256 _newMeanEntryPrice, uint256 _newMeanEntryLeverage, bool _long, uint _positionTimestampInMs) public view returns (uint256 _liquidationPrice) {

        if (_long == true) {
            _liquidationPrice = _newMeanEntryPrice.mul(_newMeanEntryLeverage.sub(PRECISION)).div(_newMeanEntryLeverage);
            _liquidationPrice = _liquidationPrice.add(calculateMarginInterest(_newMeanEntryPrice, _newMeanEntryLeverage, _positionTimestampInMs));
        } else {
            _liquidationPrice = _newMeanEntryPrice.mul(_newMeanEntryLeverage.add(PRECISION)).div(_newMeanEntryLeverage);
            _liquidationPrice = _liquidationPrice.sub(calculateMarginInterest(_newMeanEntryPrice, _newMeanEntryLeverage, _positionTimestampInMs));
        }
        return _liquidationPrice;
    }

    
    function setPositionInState(bytes32 _orderId) private {

        require(state.balanceOf(orders[_orderId].userId).add(orders[_orderId].balanceUp) >= orders[_orderId].balanceDown, "MorpherTradeEngine: insufficient funds.");
        computeLiquidationPrice(_orderId);
        if (orders[_orderId].balanceUp > orders[_orderId].balanceDown) {
            orders[_orderId].balanceUp.sub(orders[_orderId].balanceDown);
            orders[_orderId].balanceDown = 0;
        } else {
            orders[_orderId].balanceDown.sub(orders[_orderId].balanceUp);
            orders[_orderId].balanceUp = 0;
        }
        if (orders[_orderId].balanceUp > 0) {
            mintingLimiter.mint(orders[_orderId].userId, orders[_orderId].balanceUp);
        }
        if (orders[_orderId].balanceDown > 0) {
            state.burn(orders[_orderId].userId, orders[_orderId].balanceDown);
        }
        state.setPosition(
            orders[_orderId].userId,
            orders[_orderId].marketId,
            orders[_orderId].timeStamp,
            orders[_orderId].newLongShares,
            orders[_orderId].newShortShares,
            orders[_orderId].newMeanEntryPrice,
            orders[_orderId].newMeanEntrySpread,
            orders[_orderId].newMeanEntryLeverage,
            orders[_orderId].newLiquidationPrice
        );
        emit PositionUpdated(
            orders[_orderId].userId,
            orders[_orderId].marketId,
            orders[_orderId].timeStamp,
            orders[_orderId].newLongShares,
            orders[_orderId].newShortShares,
            orders[_orderId].newMeanEntryPrice,
            orders[_orderId].newMeanEntrySpread,
            orders[_orderId].newMeanEntryLeverage,
            orders[_orderId].newLiquidationPrice,
            orders[_orderId].balanceUp,
            orders[_orderId].balanceDown
        );
    }
}
pragma solidity 0.5.16;

contract IMorpherState {

    function setPosition(
        address _address,
        bytes32 _marketId,
        uint256 _timeStamp,
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    ) public; 


    function getPosition(
        address _address,
        bytes32 _marketId
    ) public view returns (
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    );


    function getLastUpdated(address _address, bytes32 _marketId) public view returns (uint256 _lastUpdated);


    function transfer(address _from, address _to, uint256 _token) public;

    
    function balanceOf(address _tokenOwner) public view returns (uint256 balance);


    function mint(address _address, uint256 _token) public;


    function burn(address _address, uint256 _token) public;


     function getSideChainOperator() public view returns (address _address);


    function inactivityPeriod() public view returns (uint256);


    function getSideChainMerkleRootWrittenAtTime() public view returns(uint256 _sideChainMerkleRoot);


    function fastTransfersEnabled() public view returns(bool);


    function mainChain() public view returns(bool);


    function setInactivityPeriod(uint256 _periodLength) public;


    function disableFastWithdraws() public;


    function setSideChainMerkleRoot(bytes32 _sideChainMerkleRoot) public;


    function resetLast24HoursAmountWithdrawn() public;


    function set24HourWithdrawLimit(uint256 _limit) public;


    function getTokenSentToLinkedChain(address _address) public view returns (uint256 _token);


    function getTokenClaimedOnThisChain(address _address) public view returns (uint256 _token);


    function getTokenSentToLinkedChainTime(address _address) public view returns (uint256 _timeStamp);


    function lastWithdrawLimitReductionTime() public view returns (uint256);


    function withdrawLimit24Hours() public view returns (uint256);


    function update24HoursWithdrawLimit(uint256 _amount) public;


    function last24HoursAmountWithdrawn() public view returns (uint256);


    function setTokenSentToLinkedChain(address _address, uint256 _token) public;


    function setTokenClaimedOnThisChain(address _address, uint256 _token) public;


    function add24HoursWithdrawn(uint256 _amount) public;


    function getPositionHash(
        address _address,
        bytes32 _marketId,
        uint256 _timeStamp,
        uint256 _longShares,
        uint256 _shortShares,
        uint256 _meanEntryPrice,
        uint256 _meanEntrySpread,
        uint256 _meanEntryLeverage,
        uint256 _liquidationPrice
    ) public pure returns (bytes32 _hash);


    function getPositionClaimedOnMainChain(bytes32 _positionHash) public view returns (bool _alreadyClaimed);


    function setPositionClaimedOnMainChain(bytes32 _positionHash) public;


     function getBalanceHash(address _address, uint256 _balance) public pure returns (bytes32 _hash);


     function getSideChainMerkleRoot() public view returns(bytes32 _sideChainMerkleRoot);


     function getBridgeNonce() public returns (uint256 _nonce);

}pragma solidity 0.5.16;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        require(proof.length < 100, "MerkleProof: proof too long. Use only sibling hashes.");
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}
pragma solidity 0.5.16;



contract MorpherOracle is Ownable {


    MorpherTradeEngine tradeEngine;
    MorpherState state; // read only, Oracle doesn't need writing access to state

    using SafeMath for uint256;

    bool public paused;
    bool public useWhiteList; //always false at the moment

    uint256 public gasForCallback;

    address payable public callBackCollectionAddress;

    mapping(address => bool) public callBackAddress;
    mapping(address => bool) public whiteList;
    
    mapping(bytes32 => uint256) public priceBelow;
    mapping(bytes32 => uint256) public priceAbove;
    mapping(bytes32 => uint256) public goodFrom;
    mapping(bytes32 => uint256) public goodUntil;

    mapping(bytes32 => bool) public orderCancellationRequested;

    mapping(bytes32 => address) public orderIdTradeEngineAddress;
    address public previousTradeEngineAddress;
    address public previousOracleAddress;

    event OrderCreated(
        bytes32 indexed _orderId,
        address indexed _address,
        bytes32 indexed _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage,
        uint256 _onlyIfPriceBelow,
        uint256 _onlyIfPriceAbove,
        uint256 _goodFrom,
        uint256 _goodUntil
        );

    event LiquidationOrderCreated(
        bytes32 indexed _orderId,
        address _sender,
        address indexed _address,
        bytes32 indexed _marketId

        );

    event OrderProcessed(
        bytes32 indexed _orderId,
        uint256 _price,
        uint256 _unadjustedMarketPrice,
        uint256 _spread,
        uint256 _positionLiquidationTimestamp,
        uint256 _timeStamp,
        uint256 _newLongShares,
        uint256 _newShortShares,
        uint256 _newMeanEntry,
        uint256 _newMeanSprad,
        uint256 _newMeanLeverage,
        uint256 _liquidationPrice
        );

    event OrderFailed(
        bytes32 indexed _orderId,
        address indexed _address,
        bytes32 indexed _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage,
        uint256 _onlyIfPriceBelow,
        uint256 _onlyIfPriceAbove,
        uint256 _goodFrom,
        uint256 _goodUntil
        );

    event OrderCancelled(
        bytes32 indexed _orderId,
        address indexed _sender,
        address indexed _oracleAddress
        );
    
    event AdminOrderCancelled(
        bytes32 indexed _orderId,
        address indexed _sender,
        address indexed _oracleAddress
        );

    event OrderCancellationRequestedEvent(
        bytes32 indexed _orderId,
        address indexed _sender
        );

    event CallbackAddressEnabled(
        address indexed _address
        );

    event CallbackAddressDisabled(
        address indexed _address
        );

    event OraclePaused(
        bool _paused
        );
        
    event CallBackCollectionAddressChange(
        address _address
        );

    event SetGasForCallback(
        uint256 _gasForCallback
        );

    event LinkTradeEngine(
        address _address
        );

    event LinkMorpherState(
        address _address
        );

    event SetUseWhiteList(
        bool _useWhiteList
        );

    event AddressWhiteListed(
        address _address
        );

    event AddressBlackListed(
        address _address
        );

    event AdminLiquidationOrderCreated(
        bytes32 indexed _orderId,
        address indexed _address,
        bytes32 indexed _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage
        );

    event DelistMarketIncomplete(bytes32 _marketId, uint256 _processedUntilIndex);
    event DelistMarketComplete(bytes32 _marketId);
    event LockedPriceForClosingPositions(bytes32 _marketId, uint256 _price);


    modifier onlyOracleOperator {

        require(isCallbackAddress(msg.sender), "MorpherOracle: Only the oracle operator can call this function.");
        _;
    }

    modifier onlyAdministrator {

        require(msg.sender == state.getAdministrator(), "Function can only be called by the Administrator.");
        _;
    }

    modifier notPaused {

        require(paused == false, "MorpherOracle: Oracle paused, aborting");
        _;
    }

   constructor(address _tradeEngineAddress, address _morpherState, address _callBackAddress, address payable _gasCollectionAddress, uint256 _gasForCallback, address _coldStorageOwnerAddress, address _previousTradeEngineAddress, address _previousOracleAddress) public {
        setTradeEngineAddress(_tradeEngineAddress);
        setStateAddress(_morpherState);
        enableCallbackAddress(_callBackAddress);
        setCallbackCollectionAddress(_gasCollectionAddress);
        setGasForCallback(_gasForCallback);
        transferOwnership(_coldStorageOwnerAddress);
        previousTradeEngineAddress = _previousTradeEngineAddress; //that is the address before updating the trade engine. Can set to 0x0000 if a completely new deployment happens. It is only valid when mid-term updating the tradeengine
        previousOracleAddress = _previousOracleAddress; //if we are updating the oracle, then this is the previous oracle address. Can be set to 0x00 if a completely new deployment happens.
    }

    function setTradeEngineAddress(address _address) public onlyOwner {

        tradeEngine = MorpherTradeEngine(_address);
        emit LinkTradeEngine(_address);
    }

    function setStateAddress(address _address) public onlyOwner {

        state = MorpherState(_address);
        emit LinkMorpherState(_address);
    }

    function overrideGasForCallback(uint256 _gasForCallback) public onlyOwner {

        gasForCallback = _gasForCallback;
        emit SetGasForCallback(_gasForCallback);
    }
    
    function setGasForCallback(uint256 _gasForCallback) private {

        gasForCallback = _gasForCallback;
        emit SetGasForCallback(_gasForCallback);
    }

    function enableCallbackAddress(address _address) public onlyOwner {

        callBackAddress[_address] = true;
        emit CallbackAddressEnabled(_address);
    }

    function disableCallbackAddress(address _address) public onlyOwner {

        callBackAddress[_address] = false;
        emit CallbackAddressDisabled(_address);
    }

    function isCallbackAddress(address _address) public view returns (bool _isCallBackAddress) {

        return callBackAddress[_address];
    }

    function setCallbackCollectionAddress(address payable _address) public onlyOwner {

        callBackCollectionAddress = _address;
        emit CallBackCollectionAddressChange(_address);
    }

    function getAdministrator() public view returns(address _administrator) {

        return state.getAdministrator();
    }

    function setUseWhiteList(bool _useWhiteList) public onlyOracleOperator {

        require(false, "MorpherOracle: Cannot use this functionality in the oracle at the moment");
        useWhiteList = _useWhiteList;
        emit SetUseWhiteList(_useWhiteList);
    }

    function setWhiteList(address _whiteList) public onlyOracleOperator {

        whiteList[_whiteList] = true;
        emit AddressWhiteListed(_whiteList);
    }

    function setBlackList(address _blackList) public onlyOracleOperator {

        whiteList[_blackList] = false;
        emit AddressBlackListed(_blackList);
    }

    function isWhiteListed(address _address) public view returns (bool _whiteListed) {

        if (useWhiteList == false ||  whiteList[_address] == true) {
            _whiteListed = true;
        }
        return(_whiteListed);
    }

    function emitOrderFailed(
        bytes32 _orderId,
        address _address,
        bytes32 _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage,
        uint256 _onlyIfPriceBelow,
        uint256 _onlyIfPriceAbove,
        uint256 _goodFrom,
        uint256 _goodUntil
    ) public onlyOracleOperator {

        emit OrderFailed(
            _orderId,
            _address,
            _marketId,
            _closeSharesAmount,
            _openMPHTokenAmount,
            _tradeDirection,
            _orderLeverage,
            _onlyIfPriceBelow,
            _onlyIfPriceAbove,
            _goodFrom,
            _goodUntil);
    }

    function createOrder(
        bytes32 _marketId,
        uint256 _closeSharesAmount,
        uint256 _openMPHTokenAmount,
        bool _tradeDirection,
        uint256 _orderLeverage,
        uint256 _onlyIfPriceAbove,
        uint256 _onlyIfPriceBelow,
        uint256 _goodUntil,
        uint256 _goodFrom
        ) public payable notPaused returns (bytes32 _orderId) {

        require(isWhiteListed(msg.sender),"MorpherOracle: Address not eligible to create an order.");
        if (gasForCallback > 0) {
            require(msg.value >= gasForCallback, "MorpherOracle: Must transfer gas costs for Oracle Callback function.");
            callBackCollectionAddress.transfer(msg.value);
        }
        _orderId = tradeEngine.requestOrderId(msg.sender, _marketId, _closeSharesAmount, _openMPHTokenAmount, _tradeDirection, _orderLeverage);
        orderIdTradeEngineAddress[_orderId] = address(tradeEngine);

        if(state.getMarketActive(_marketId) == false) {

            tradeEngine.processOrder(_orderId, tradeEngine.getDeactivatedMarketPrice(_marketId), 0, 0, now.mul(1000));
            
            emit OrderProcessed(
                _orderId,
                tradeEngine.getDeactivatedMarketPrice(_marketId),
                0,
                0,
                0,
                now.mul(1000),
                0,
                0,
                0,
                0,
                0,
                0
                );
        } else {
            priceAbove[_orderId] = _onlyIfPriceAbove;
            priceBelow[_orderId] = _onlyIfPriceBelow;
            goodFrom[_orderId]   = _goodFrom;
            goodUntil[_orderId]  = _goodUntil;
            emit OrderCreated(
                _orderId,
                msg.sender,
                _marketId,
                _closeSharesAmount,
                _openMPHTokenAmount,
                _tradeDirection,
                _orderLeverage,
                _onlyIfPriceBelow,
                _onlyIfPriceAbove,
                _goodFrom,
                _goodUntil
                );
        }

        return _orderId;
    }

    function getTradeEngineFromOrderId(bytes32 _orderId) public view returns (address) {

        if(orderIdTradeEngineAddress[_orderId] != address(0)){
            return orderIdTradeEngineAddress[_orderId];
        }


        return previousTradeEngineAddress;
    }

    function initiateCancelOrder(bytes32 _orderId) public {

        MorpherTradeEngine _tradeEngine = MorpherTradeEngine(getTradeEngineFromOrderId(_orderId));
        require(orderCancellationRequested[_orderId] == false, "MorpherOracle: Order was already canceled.");
        (address userId, , , , , , ) = _tradeEngine.getOrder(_orderId);
        require(userId == msg.sender, "MorpherOracle: Only the user can request an order cancellation.");
        orderCancellationRequested[_orderId] = true;
        emit OrderCancellationRequestedEvent(_orderId, msg.sender);

    }
    function cancelOrder(bytes32 _orderId) public onlyOracleOperator {

        require(orderCancellationRequested[_orderId] == true, "MorpherOracle: Order-Cancellation was not requested.");
        MorpherTradeEngine _tradeEngine = MorpherTradeEngine(getTradeEngineFromOrderId(_orderId));
        (address userId, , , , , , ) = _tradeEngine.getOrder(_orderId);
        _tradeEngine.cancelOrder(_orderId, userId);
        clearOrderConditions(_orderId);
        emit OrderCancelled(
            _orderId,
            userId,
            msg.sender
            );
    }
    
    function adminCancelOrder(bytes32 _orderId) public onlyOracleOperator {

        MorpherTradeEngine _tradeEngine = MorpherTradeEngine(getTradeEngineFromOrderId(_orderId));
        (address userId, , , , , , ) = _tradeEngine.getOrder(_orderId);
        _tradeEngine.cancelOrder(_orderId, userId);
        clearOrderConditions(_orderId);
        emit AdminOrderCancelled(
            _orderId,
            userId,
            msg.sender
            );
    }

    function getGoodUntil(bytes32 _orderId) public view returns(uint) {

        if(goodUntil[_orderId] > 0) {
            return goodUntil[_orderId];
        }

        if(previousOracleAddress != address(0)) {
            MorpherOracle _oldOracle = MorpherOracle(previousOracleAddress);
            return _oldOracle.goodUntil(_orderId);
        }

        return 0;
    }
    function getGoodFrom(bytes32 _orderId) public view returns(uint) {

        if(goodFrom[_orderId] > 0) {
            return goodFrom[_orderId];
        }

        if(previousOracleAddress != address(0)) {
            MorpherOracle _oldOracle = MorpherOracle(previousOracleAddress);
            return _oldOracle.goodFrom(_orderId);
        }
        return 0;
    }
    function getPriceAbove(bytes32 _orderId) public view returns(uint) {

        if(priceAbove[_orderId] > 0) {
            return priceAbove[_orderId];
        }

        if(previousOracleAddress != address(0)) {
            MorpherOracle _oldOracle = MorpherOracle(previousOracleAddress);
            return _oldOracle.priceAbove(_orderId);
        }
        return 0;
    }
    function getPriceBelow(bytes32 _orderId) public view returns(uint) {

        if(priceBelow[_orderId] > 0) {
            return priceBelow[_orderId];
        }

        if(previousOracleAddress != address(0)) {
            MorpherOracle _oldOracle = MorpherOracle(previousOracleAddress);
            return _oldOracle.priceBelow(_orderId);
        }
        return 0;
    }

    function checkOrderConditions(bytes32 _orderId, uint256 _price) public view returns (bool _conditionsMet) {

        _conditionsMet = true;
        if (now > getGoodUntil(_orderId) && getGoodUntil(_orderId) > 0) {
            _conditionsMet = false;
        }
        if (now < getGoodFrom(_orderId) && getGoodFrom(_orderId) > 0) {
            _conditionsMet = false;
        }

        if(getPriceAbove(_orderId) > 0 && getPriceBelow(_orderId) > 0) {
            if(_price < getPriceAbove(_orderId) && _price > getPriceBelow(_orderId)) {
                _conditionsMet = false;
            }
        } else {
            if (_price < getPriceAbove(_orderId) && getPriceAbove(_orderId) > 0) {
                _conditionsMet = false;
            }
            if (_price > getPriceBelow(_orderId) && getPriceBelow(_orderId) > 0) {
                _conditionsMet = false;
            }
        }
        
        return _conditionsMet;
    }

    function clearOrderConditions(bytes32 _orderId) internal {

        priceAbove[_orderId] = 0;
        priceBelow[_orderId] = 0;
        goodFrom[_orderId]   = 0;
        goodUntil[_orderId]  = 0;
    }

    function pauseOracle() public onlyOwner {

        paused = true;
        emit OraclePaused(true);
    }

    function unpauseOracle() public onlyOwner {

        paused = false;
        emit OraclePaused(false);
    }

    function createLiquidationOrder(
        address _address,
        bytes32 _marketId
        ) public notPaused onlyOracleOperator payable returns (bytes32 _orderId) {

        if (gasForCallback > 0) {
            require(msg.value >= gasForCallback, "MorpherOracle: Must transfer gas costs for Oracle Callback function.");
            callBackCollectionAddress.transfer(msg.value);
        }
        _orderId = tradeEngine.requestOrderId(_address, _marketId, 0, 0, true, 10**8);
        orderIdTradeEngineAddress[_orderId] = address(tradeEngine);
        emit LiquidationOrderCreated(_orderId, msg.sender, _address, _marketId);
        return _orderId;
    }

    function __callback(
        bytes32 _orderId,
        uint256 _price,
        uint256 _unadjustedMarketPrice,
        uint256 _spread,
        uint256 _liquidationTimestamp,
        uint256 _timeStamp,
        uint256 _gasForNextCallback
        ) public onlyOracleOperator notPaused returns (uint256 _newLongShares, uint256 _newShortShares, uint256 _newMeanEntry, uint256 _newMeanSpread, uint256 _newMeanLeverage, uint256 _liquidationPrice)  {

        
        require(checkOrderConditions(_orderId, _price), 'MorpherOracle Error: Order Conditions are not met');
       
       MorpherTradeEngine _tradeEngine = MorpherTradeEngine(getTradeEngineFromOrderId(_orderId));
        (
            _newLongShares,
            _newShortShares,
            _newMeanEntry,
            _newMeanSpread,
            _newMeanLeverage,
            _liquidationPrice
        ) = _tradeEngine.processOrder(_orderId, _price, _spread, _liquidationTimestamp, _timeStamp);
        
        clearOrderConditions(_orderId);
        emit OrderProcessed(
            _orderId,
            _price,
            _unadjustedMarketPrice,
            _spread,
            _liquidationTimestamp,
            _timeStamp,
            _newLongShares,
            _newShortShares,
            _newMeanEntry,
            _newMeanSpread,
            _newMeanLeverage,
            _liquidationPrice
            );
        setGasForCallback(_gasForNextCallback);
        return (_newLongShares, _newShortShares, _newMeanEntry, _newMeanSpread, _newMeanLeverage, _liquidationPrice);
    }


    uint delistMarketFromIx = 0;
    function delistMarket(bytes32 _marketId, bool _startFromScratch) public onlyAdministrator {

        require(state.getMarketActive(_marketId) == true, "Market must be active to process position liquidations.");
        if (_startFromScratch) {
            delistMarketFromIx = 0;
        }
        
        uint _toIx = state.getMaxMappingIndex(_marketId);
        
        address _address;
        for (uint256 i = delistMarketFromIx; i <= _toIx; i++) {
             if(gasleft() < 250000 && i != _toIx) { //stop if there's not enough gas to write the next transaction
                delistMarketFromIx = i;
                emit DelistMarketIncomplete(_marketId, _toIx);
                return;
            } 
            
            _address = state.getExposureMappingAddress(_marketId, i);
            adminLiquidationOrder(_address, _marketId);
            
        }
        emit DelistMarketComplete(_marketId);
    }

    function setDeactivatedMarketPrice(bytes32 _marketId, uint256 _price) public onlyAdministrator {

        tradeEngine.setDeactivatedMarketPrice(_marketId, _price);
        emit LockedPriceForClosingPositions(_marketId, _price);

    }

    function adminLiquidationOrder(
        address _address,
        bytes32 _marketId
        ) public onlyAdministrator returns (bytes32 _orderId) {

            uint256 _positionLongShares = state.getLongShares(_address, _marketId);
            uint256 _positionShortShares = state.getShortShares(_address, _marketId);
            if (_positionLongShares > 0) {
                _orderId = tradeEngine.requestOrderId(_address, _marketId, _positionLongShares, 0, false, 10**8);
                emit AdminLiquidationOrderCreated(_orderId, _address, _marketId, _positionLongShares, 0, false, 10**8);
            }
            if (_positionShortShares > 0) {
                _orderId = tradeEngine.requestOrderId(_address, _marketId, _positionShortShares, 0, true, 10**8);
                emit AdminLiquidationOrderCreated(_orderId, _address, _marketId, _positionShortShares, 0, true, 10**8);
            }
            orderIdTradeEngineAddress[_orderId] = address(tradeEngine);
            return _orderId;
    }
    
    function stringToHash(string memory _source) public pure returns (bytes32 _result) {

        return keccak256(abi.encodePacked(_source));
    }
}
pragma solidity 0.5.16;



contract MorpherStaking is Ownable {

    using SafeMath for uint256;
    IMorpherState state;

    uint256 constant PRECISION = 10**8;
    uint256 constant INTERVAL  = 1 days;


    uint256 public poolShareValue = PRECISION;
    uint256 public lastReward;
    uint256 public totalShares;
    uint256 public interestRate = 15000; // 0.015% per day initially, diminishing returns over time
    uint256 public lockupPeriod = 30 days; // to prevent tactical staking and ensure smooth governance
    uint256 public minimumStake = 10**23; // 100k MPH minimum

    address public stakingAdmin;

    address public stakingAddress = 0x2222222222222222222222222222222222222222;
    bytes32 public marketIdStakingMPH = 0x9a31fdde7a3b1444b1befb10735dcc3b72cbd9dd604d2ff45144352bf0f359a6; //STAKING_MPH

    event SetInterestRate(uint256 newInterestRate);
    event SetLockupPeriod(uint256 newLockupPeriod);
    event SetMinimumStake(uint256 newMinimumStake);
    event LinkState(address stateAddress);
    event SetStakingAdmin(address stakingAdmin);
    
    event PoolShareValueUpdated(uint256 indexed lastReward, uint256 poolShareValue);
    event StakingRewardsMinted(uint256 indexed lastReward, uint256 delta);
    event Staked(address indexed userAddress, uint256 indexed amount, uint256 poolShares, uint256 lockedUntil);
    event Unstaked(address indexed userAddress, uint256 indexed amount, uint256 poolShares);
    
    modifier onlyStakingAdmin {

        require(msg.sender == stakingAdmin, "MorpherStaking: can only be called by Staking Administrator.");
        _;
    }
    
    constructor(address _morpherState, address _stakingAdmin) public {
        setStakingAdmin(_stakingAdmin);
        setMorpherStateAddress(_morpherState);
        emit SetLockupPeriod(lockupPeriod);
        emit SetMinimumStake(minimumStake);
        emit SetInterestRate(interestRate);
        lastReward = now;
    }

    
    function updatePoolShareValue() public returns (uint256 _newPoolShareValue) {

        if (now >= lastReward.add(INTERVAL)) {
            uint256 _numOfIntervals = now.sub(lastReward).div(INTERVAL);
            poolShareValue = poolShareValue.add(_numOfIntervals.mul(interestRate));
            lastReward = lastReward.add(_numOfIntervals.mul(INTERVAL));
            emit PoolShareValueUpdated(lastReward, poolShareValue);
        }
        mintStakingRewards();
        return poolShareValue;        
    }


    function mintStakingRewards() private {

        uint256 _targetBalance = poolShareValue.mul(totalShares);
        if (state.balanceOf(stakingAddress) < _targetBalance) {
            uint256 _delta = _targetBalance.sub(state.balanceOf(stakingAddress));
            state.mint(stakingAddress, _delta);
            emit StakingRewardsMinted(lastReward, _delta);
        }
    }


    function stake(uint256 _amount) public returns (uint256 _poolShares) {

        require(state.balanceOf(msg.sender) >= _amount, "MorpherStaking: insufficient MPH token balance");
        updatePoolShareValue();
        _poolShares = _amount.div(poolShareValue);
        (uint256 _numOfShares, , , , , ) = state.getPosition(msg.sender, marketIdStakingMPH);
        require(minimumStake <= _numOfShares.add(_poolShares).mul(poolShareValue), "MorpherStaking: stake amount lower than minimum stake");
        state.transfer(msg.sender, stakingAddress, _poolShares.mul(poolShareValue));
        totalShares = totalShares.add(_poolShares);
        state.setPosition(msg.sender, marketIdStakingMPH, now.add(lockupPeriod), _numOfShares.add(_poolShares), 0, 0, 0, 0, 0);
        emit Staked(msg.sender, _amount, _poolShares, now.add(lockupPeriod));
        return _poolShares;
    }


    function unstake(uint256 _numOfShares) public returns (uint256 _amount) {

        (uint256 _numOfExistingShares, , , , , ) = state.getPosition(msg.sender, marketIdStakingMPH);
        require(_numOfShares <= _numOfExistingShares, "MorpherStaking: insufficient pool shares");

        uint256 lockedInUntil = state.getLastUpdated(msg.sender, marketIdStakingMPH);
        require(now >= lockedInUntil, "MorpherStaking: cannot unstake before lockup expiration");
        updatePoolShareValue();
        state.setPosition(msg.sender, marketIdStakingMPH, lockedInUntil, _numOfExistingShares.sub(_numOfShares), 0, 0, 0, 0, 0);
        totalShares = totalShares.sub(_numOfShares);
        _amount = _numOfShares.mul(poolShareValue);
        state.transfer(stakingAddress, msg.sender, _amount);
        emit Unstaked(msg.sender, _amount, _numOfShares);
        return _amount;
    }


    function setStakingAdmin(address _address) public onlyOwner {

        stakingAdmin = _address;
        emit SetStakingAdmin(_address);
    }

    function setMorpherStateAddress(address _stateAddress) public onlyOwner {

        state = IMorpherState(_stateAddress);
        emit LinkState(_stateAddress);
    }

    function setInterestRate(uint256 _interestRate) public onlyStakingAdmin {

        interestRate = _interestRate;
        emit SetInterestRate(_interestRate);
    }

    function setLockupPeriodRate(uint256 _lockupPeriod) public onlyStakingAdmin {

        lockupPeriod = _lockupPeriod;
        emit SetLockupPeriod(_lockupPeriod);
    }
    
    function setMinimumStake(uint256 _minimumStake) public onlyStakingAdmin {

        minimumStake = _minimumStake;
        emit SetMinimumStake(_minimumStake);
    }


    function getTotalPooledValue() public view returns (uint256 _totalPooled) {

        return poolShareValue.mul(totalShares);
    }

    function getStake(address _address) public view returns (uint256 _poolShares) {

        (uint256 _numOfShares, , , , , ) = state.getPosition(_address, marketIdStakingMPH);
        return _numOfShares;
    }

    function getStakeValue(address _address) public view returns(uint256 _value, uint256 _lastUpdate) {

        
        (uint256 _numOfShares, , , , , ) = state.getPosition(_address, marketIdStakingMPH);

        return (_numOfShares.mul(poolShareValue), lastReward);
    }
    

    function () external payable {
        revert("MorpherStaking: you can't deposit Ether here");
    }
}
pragma solidity 0.5.16;


contract MorpherToken is IERC20, Ownable {


    MorpherState state;
    using SafeMath for uint256;

    string public constant name     = "Morpher";
    string public constant symbol   = "MPH";
    uint8  public constant decimals = 18;
    
    modifier onlyState {

        require(msg.sender == address(state), "ERC20: caller must be MorpherState contract.");
        _;
    }

    modifier canTransfer {

        require(state.getCanTransfer(msg.sender), "ERC20: token transfers disabled on sidechain.");
        _;
    }
    
    event LinkState(address _address);

    constructor(address _stateAddress, address _coldStorageOwnerAddress) public {
        setMorpherState(_stateAddress);
        transferOwnership(_coldStorageOwnerAddress);
    }

    function setMorpherState(address _stateAddress) public onlyOwner {

        state = MorpherState(_stateAddress);
        emit LinkState(_stateAddress);
    }

    function totalSupply() public view returns (uint256) {

        return state.totalSupply();
    }

    function balanceOf(address _account) public view returns (uint256) {

        return state.balanceOf(_account);
    }

    function transfer(address _recipient, uint256 _amount) public returns (bool) {

        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return state.getAllowance(_owner, _spender);
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {

        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 amount) public returns (bool) {

        _transfer(_sender, _recipient, amount);
        _approve(_sender, msg.sender, state.getAllowance(_sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {

        _approve(msg.sender, _spender, state.getAllowance(msg.sender, _spender).add(_addedValue));
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {

        _approve(msg.sender, _spender,  state.getAllowance(msg.sender, _spender).sub(_subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     function burn(uint256 _amount) public returns (bool) {

        state.burn(msg.sender, _amount);
        return true;
    }

     function emitTransfer(address _from, address _to, uint256 _amount) public onlyState {

        emit Transfer(_from, _to, _amount);
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) canTransfer internal {

        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(state.balanceOf(_sender) >= _amount, "ERC20: transfer amount exceeds balance");
        state.transfer(_sender, _recipient, _amount);
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal {

        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        state.setAllowance(_owner, _spender, _amount);
        emit Approval(_owner, _spender, _amount);
    }

    function () external payable {
        revert("ERC20: You can't deposit Ether here");
    }
}
