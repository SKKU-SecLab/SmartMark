
pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}
contract ETORoles {

        using Roles for Roles.Role;

        constructor() internal {
                _addAuditWriter(msg.sender);
                _addAssetSeizer(msg.sender);
                _addKycProvider(msg.sender);
                _addAssetFreezer(msg.sender);
                _addUserManager(msg.sender);
                _addOwner(msg.sender);
        }

        event AuditWriterAdded(address indexed account);
        event AuditWriterRemoved(address indexed account);

        Roles.Role private _auditWriters;

        modifier onlyAuditWriter() {

                require(isAuditWriter(msg.sender));
                _;
        }

        function isAuditWriter(address account) public view returns (bool) {

                return _auditWriters.has(account);
        }

        function addAuditWriter(address account) public onlyUserManager {

                _addAuditWriter(account);
        }

        function renounceAuditWriter() public {

                _removeAuditWriter(msg.sender);
        }

        function _addAuditWriter(address account) internal {

                _auditWriters.add(account);
                emit AuditWriterAdded(account);
        }

        function _removeAuditWriter(address account) internal {

                _auditWriters.remove(account);
                emit AuditWriterRemoved(account);
        }

        event KycProviderAdded(address indexed account);
        event KycProviderRemoved(address indexed account);

        Roles.Role private _kycProviders;

        modifier onlyKycProvider() {

                require(isKycProvider(msg.sender));
                _;
        }

        function isKycProvider(address account) public view returns (bool) {

                return _kycProviders.has(account);
        }

        function addKycProvider(address account) public onlyUserManager {

                _addKycProvider(account);
        }

        function renounceKycProvider() public {

                _removeKycProvider(msg.sender);
        }

        function _addKycProvider(address account) internal {

                _kycProviders.add(account);
                emit KycProviderAdded(account);
        }

        function _removeKycProvider(address account) internal {

                _kycProviders.remove(account);
                emit KycProviderRemoved(account);
        }

        event AssetSeizerAdded(address indexed account);
        event AssetSeizerRemoved(address indexed account);

        Roles.Role private _assetSeizers;

        modifier onlyAssetSeizer() {

                require(isAssetSeizer(msg.sender));
                _;
        }

        function isAssetSeizer(address account) public view returns (bool) {

                return _assetSeizers.has(account);
        }

        function addAssetSeizer(address account) public onlyUserManager {

                _addAssetSeizer(account);
        }

        function renounceAssetSeizer() public {

                _removeAssetSeizer(msg.sender);
        }

        function _addAssetSeizer(address account) internal {

                _assetSeizers.add(account);
                emit AssetSeizerAdded(account);
        }

        function _removeAssetSeizer(address account) internal {

                _assetSeizers.remove(account);
                emit AssetSeizerRemoved(account);
        }

        event AssetFreezerAdded(address indexed account);
        event AssetFreezerRemoved(address indexed account);

        Roles.Role private _assetFreezers;

        modifier onlyAssetFreezer() {

                require(isAssetFreezer(msg.sender));
                _;
        }

        function isAssetFreezer(address account) public view returns (bool) {

                return _assetFreezers.has(account);
        }

        function addAssetFreezer(address account) public onlyUserManager {

                _addAssetFreezer(account);
        }

        function renounceAssetFreezer() public {

                _removeAssetFreezer(msg.sender);
        }

        function _addAssetFreezer(address account) internal {

                _assetFreezers.add(account);
                emit AssetFreezerAdded(account);
        }

        function _removeAssetFreezer(address account) internal {

                _assetFreezers.remove(account);
                emit AssetFreezerRemoved(account);
        }

        event UserManagerAdded(address indexed account);
        event UserManagerRemoved(address indexed account);

        Roles.Role private _userManagers;

        modifier onlyUserManager() {

                require(isUserManager(msg.sender));
                _;
        }

        function isUserManager(address account) public view returns (bool) {

                return _userManagers.has(account);
        }

        function addUserManager(address account) public onlyUserManager {

                _addUserManager(account);
        }

        function renounceUserManager() public {

                _removeUserManager(msg.sender);
        }

        function _addUserManager(address account) internal {

                _userManagers.add(account);
                emit UserManagerAdded(account);
        }

        function _removeUserManager(address account) internal {

                _userManagers.remove(account);
                emit UserManagerRemoved(account);
        }
        
        event OwnerAdded(address indexed account);
        event OwnerRemoved(address indexed account);

        Roles.Role private _owners;

        modifier onlyOwner() {

                require(isOwner(msg.sender));
                _;
        }

        function isOwner(address account) public view returns (bool) {

                return _owners.has(account);
        }

        function addOwner(address account) public onlyUserManager {

                _addOwner(account);
        }

        function renounceOwner() public {

                _removeOwner(msg.sender);
        }

        function _addOwner(address account) internal {

                _owners.add(account);
                emit OwnerAdded(account);
        }

        function _removeOwner(address account) internal {

                _owners.remove(account);
                emit OwnerRemoved(account);
        }
        
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC20Mintable is ERC20, MinterRole {

    function mint(address to, uint256 value) public onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }
}


contract ETOToken is ERC20Mintable, ETORoles {

    enum AssetStatuses {ACTIVE, FROZEN, ISSUED, LISTED, INESCROW}
    enum CompanyStatuses {ININCORPORATION, ACTIVE, INLIQUIDATION}
    struct TokenCapabilities {
        bool Voting;
        bool Dividend;
        string[] CorporateActions;
    }

    mapping(address => bool) investorWhitelist;
    address[] investorWhitelistLUT;

    string public constant tokenName = "ETOToken";
    string public constant symbol = "ETO";
    uint8 public constant decimals = 0;

    string public ISIN;
    string public ITIN;
    string public ValorNumber;
    AssetStatuses public AssetStatus;
    uint256 public LiquidationProceeds;
    string public TaxDomicile;
    TokenCapabilities public Capabilities;
    uint256 public VotePercentage;
    uint256 public IssuancePrice;
    string[] public Currencies;
    uint256 public SalesStart;
    uint256 public SalesEnd;
    uint256 public TradeStart;
    uint256 public IssuanceStart;
    uint256 public IssuePaymentDate;
    uint256 public InitialFixingDate;
    string public MarketMaker;
    string public MainPayingAgent;
    uint256 public SmallestTradableDenomination;
    uint256 public TickSize;
    uint256 public NextDividendDate;
    string public DividendType;
    uint256 public DividendTax;
    uint256 public PercentageDividend;
    string public CompanyName;
    CompanyStatuses public CompanyStatus;
    string public CompanyLegalForm;

    mapping(uint256 => uint256) auditHashes;
    
    mapping(uint256 => uint256) documentHashes;

    event AssetsSeized(address seizee, uint256 amount);
    event AssetsUnseized(address seizee, uint256 amount);
    event InvestorWhitelisted(address investor);
    event InvestorBlacklisted(address investor);
    event DividendPayout(address receiver, uint256 amount);
    event TokensGenerated(uint256 amount);
    event OwnershipUpdated(address newOwner);

    constructor() public {
        AssetStatus = AssetStatuses.ACTIVE;
        TaxDomicile = "CH";
        Capabilities.Voting = true;
        Capabilities.Dividend = true;
        CompanyName = "BlockState";
        CompanyStatus = CompanyStatuses.ACTIVE;
        CompanyLegalForm = "AG";
    }

    event ISINUpdated(string newValue);
    event ITINUpdated(string newValue);
    event ValorNumberUpdated(string newValue);
    event AssetStatusUpdated(AssetStatuses newValue);
    event LiquidationProceedsUpdated(uint256 newValue);
    event CurrenciesUpdated(string[]  newValue);
    event TaxDomicileUpdated(string newValue);
    event CapabilitiesUpdated(TokenCapabilities newValue);
    event VotePercentageUpdated(uint256 newValue);
    event IssuancePriceUpdated(uint256 newValue);
    event SalesStartUpdated(uint256 newValue);
    event SalesEndUpdated(uint256 newValue);
    event TradeStartUpdated(uint256 newValue);
    event IssuanceStartUpdated(uint256 newValue);
    event IssuePaymentDateUpdated(uint256 newValue);
    event InitialFixingDateUpdated(uint256 newValue);
    event MarketMakerUpdated(string newValue);
    event MainPayingAgentUpdated(string newValue);
    event SmallestTradableDenominationUpdated(uint256 newValue);
    event TickSizeUpdated(uint256 newValue);
    event NextDividendDateUpdated(uint256 newValue);
    event DividendTypeUpdated(string newValue);
    event DividendTaxUpdated(uint256 newValue);
    event PercentageDividendUpdated(uint256 newValue);
    event CompanyNameUpdated(string newValue);
    event CompanyStatusUpdated(CompanyStatuses newValue);
    event CompanyLegalFormUpdated(string newValue);

    function setISIN(string memory newValue) public onlyOwner {

        ISIN = newValue;
        emit ISINUpdated(newValue);
    }
    function setITIN(string memory newValue) public onlyOwner {

        ITIN = newValue;
        emit ITINUpdated(newValue);
    }
    function setValorNumber(string memory newValue) public onlyOwner {

        ValorNumber = newValue;
        emit ValorNumberUpdated(newValue);
    }
        function setAssetStatus(AssetStatuses newValue) public onlyOwner {

                AssetStatus = newValue;
                emit AssetStatusUpdated(newValue);
        }
        function setLiquidationProceeds(uint256 newValue) public onlyOwner {

                LiquidationProceeds = newValue;
                emit LiquidationProceedsUpdated(newValue);
        }
        function setTaxDomicile(string memory newValue) public onlyOwner {

                TaxDomicile= newValue;
                emit TaxDomicileUpdated(newValue);
        }
        function setCapabilities(TokenCapabilities memory newValue) public onlyOwner {

                Capabilities = newValue;
                emit CapabilitiesUpdated(newValue);
        }
        function setVotePercentage(uint256 newValue) public onlyOwner {

                VotePercentage = newValue;
                emit VotePercentageUpdated(newValue);
        }
        function setIssuancePrice(uint256 newValue) public onlyOwner {

                IssuancePrice = newValue;
                emit IssuancePriceUpdated(newValue);
        }
        function setCurrencies(string[] memory newValue) public onlyOwner {

                Currencies = newValue;
                emit CurrenciesUpdated(newValue);
        }
        function setSalesStart(uint256 newValue) public onlyOwner {

                SalesStart = newValue;
                emit SalesStartUpdated(newValue);
        }
        function setSalesEnd(uint256 newValue) public onlyOwner {

                SalesEnd = newValue;
                emit SalesEndUpdated(newValue);
        }
        function setTradeStart(uint256 newValue) public onlyOwner {

                TradeStart = newValue;
                emit TradeStartUpdated(newValue);
        }
        function setIssuanceStart(uint256 newValue) public onlyOwner {

                IssuanceStart = newValue;
                emit IssuanceStartUpdated(newValue);
        }
        function setIssuePaymentDate(uint256 newValue) public onlyOwner {

                IssuePaymentDate = newValue;
                emit IssuePaymentDateUpdated(newValue);
        }
        function setInitialFixingDate(uint256 newValue) public onlyOwner {

                InitialFixingDate = newValue;
                emit InitialFixingDateUpdated(newValue);
        }
        function setMarketMaker(string memory newValue) public onlyOwner {

                MarketMaker = newValue;
                emit MarketMakerUpdated(newValue);
        }
        function setMainPayingAgent(string memory newValue) public onlyOwner {

                MainPayingAgent = newValue;
                emit MainPayingAgentUpdated(newValue);
        }
        function setSmallestTradableDenomination(uint256 newValue) public onlyOwner {

                SmallestTradableDenomination = newValue;
                emit SmallestTradableDenominationUpdated(newValue);
        }
        function setTickSize(uint256 newValue) public onlyOwner {

                TickSize = newValue;
                emit TickSizeUpdated(newValue);
        }
        function setNextDividendDate(uint256 newValue) public onlyOwner {

                NextDividendDate = newValue;
                emit NextDividendDateUpdated(newValue);
        }
        function setDividendType(string memory newValue) public onlyOwner {

                DividendType = newValue;
                emit DividendTypeUpdated(newValue);
        }
        function setDividendTax(uint256 newValue) public onlyOwner {

                DividendTax = newValue;
                emit DividendTaxUpdated(newValue);
        }
        function setPercentageDividend(uint256 newValue) public onlyOwner {

                PercentageDividend = newValue;
                emit PercentageDividendUpdated(newValue);
        }
        function setCompanyName(string memory newValue) public onlyOwner {

                CompanyName = newValue;
                emit CompanyNameUpdated(newValue);
        }
        function setCompanyStatus(CompanyStatuses newValue) public onlyOwner {

                CompanyStatus = newValue;
                emit CompanyStatusUpdated(newValue);
        }
        function setCompanyLegalForm(string memory newValue) public onlyOwner {

                CompanyLegalForm = newValue;
                emit CompanyLegalFormUpdated(newValue);
        }

        function seizeAssets(address seizee, uint256 seizableAmount) public onlyAssetSeizer {

                require(balanceOf(seizee) >= seizableAmount);
                transferFrom(seizee, msg.sender, seizableAmount);
                emit AssetsSeized(seizee, seizableAmount);
        }

        function releaseAssets(address seizee, uint256 seizedAmount) public onlyAssetSeizer {

                require(balanceOf(msg.sender) >= seizedAmount);
                transferFrom(msg.sender, seizee, seizedAmount);
                emit AssetsUnseized(seizee, seizedAmount);
        }

        function whitelistInvestor(address investor) public onlyKycProvider {

                investorWhitelist[investor] = true;
                investorWhitelistLUT.push(investor);
                emit InvestorWhitelisted(investor);
        }

        function blacklistInvestor(address investor) public onlyKycProvider {

                investorWhitelist[investor] = false;
                for (uint i = 0; i < investorWhitelistLUT.length; i++) {
                        if (investorWhitelistLUT[i] == investor) {
                                investorWhitelistLUT[i] = investorWhitelistLUT[investorWhitelistLUT.length];
                                delete investorWhitelistLUT[investorWhitelistLUT.length];
                                break;
                        }
                }
                emit InvestorBlacklisted(investor);
        }

        function transfer(address _to, uint256 _value) public returns (bool) {

                require(investorWhitelist[_to] == true);
                return super.transfer(_to, _value);
        }

        function generateTokens(uint256 amount, address assetReceiver) public onlyOwner {

                _mint(assetReceiver, amount);
        }

        function initiateDividendPayments(uint amount) public returns (bool) {

                uint dividendPerToken = amount / totalSupply();
                for (uint i = 0; i < investorWhitelistLUT.length; i++) {
                        address currentInvestor = investorWhitelistLUT[i];
                        uint256 currentInvestorShares = balanceOf(currentInvestor);
                        uint256 currentInvestorPayout = dividendPerToken * currentInvestorShares;
                        emit DividendPayout(currentInvestor, currentInvestorPayout);
                }
        }

        function addAuditHash(uint256 hash) public onlyAuditWriter {

                auditHashes[now] = hash;
        }

        function getAuditHash(uint256 timestamp) public view returns (uint256) {

                return auditHashes[timestamp];
        }
        
        function addDocumentHash(uint256 hash) public onlyOwner {                      

            documentHashes[now] = hash;                                                
        }
        
        function getDocumentHash(uint256 timestamp) public view returns (uint256) {

            return documentHashes[timestamp];
        }
}

contract ETOVotes is ETOToken {

    event VoteOpen(uint256 _id, uint _deadline);
    event VoteFinished(uint256 _id, bool _result);

    mapping (uint256 => Vote) private votes;

    struct Voter {
        address id;
        bool vote;
    }

    struct Vote {
        uint256 deadline;
        Voter[] voters;
        mapping(address => uint) votersIndex;
        uint256 documentHash;
    }

    constructor() public {}

    function vote(uint256 _id, bool _vote) public {

        require (votes[_id].deadline > 0, "Vote not available");
        require(now <= votes[_id].deadline, "Vote deadline exceeded");
        if (didCastVote(_id)) {
            uint256 currentIndex = votes[_id].votersIndex[msg.sender];
            Voter memory newVoter = Voter(msg.sender, _vote);
            votes[_id].voters[currentIndex] = newVoter;
        } else {
            votes[_id].voters.push(Voter(msg.sender, _vote));
            votes[_id].votersIndex[msg.sender] = votes[_id].voters.length;
        }
    }

    function openVote(uint256 _id, uint256 documentHash, uint256 voteDuration) external {

        require(votes[_id].deadline == 0, "Vote already ongoing");
        votes[_id].deadline = now + (voteDuration * 1 seconds);
        votes[_id].documentHash = documentHash;
        emit VoteOpen(_id, votes[_id].deadline);
    }

    function triggerDecision(uint256 _id) external {

        require(votes[_id].deadline > 0, "Vote not available");
        require(now > votes[_id].deadline, "Vote deadline not reached");
        votes[_id].deadline = 0;
        uint256 negativeVotes = 0;
        uint256 positiveVotes = 0;
        uint totalVoters = votes[_id].voters.length;
        for (uint i = 0; i < totalVoters; i++){
            if (votes[_id].voters[i].vote)
                negativeVotes++;
            else
                positiveVotes++;
        }
        bool result = (positiveVotes > negativeVotes);
        emit VoteFinished(_id, result);
    }

    function isVoteOpen(uint256 _id) external view returns (bool) {

        return (votes[_id].deadline > 0) && (now <= votes[_id].deadline);
    }

    function didCastVote(uint256 _id) public view returns (bool) {

        return (votes[_id].votersIndex[msg.sender] > 0);
    }
        
    function getOwnVote(uint256 _id) public view returns (bool) {

        uint voterId = votes[_id].votersIndex[msg.sender];
        return votes[_id].voters[voterId-1].vote;
    }
    
    function getCurrentPositives(uint256 _id) public view returns (uint256) {

        uint adder = 0;
        for (uint256 i = 0; i < votes[_id].voters.length; i++) {
            if (votes[_id].voters[i].vote == true) {
                adder += balanceOf(votes[_id].voters[i].id);
            }
        }
        return adder;
    }
    
    function getCurrentNegatives(uint256 _id) public view returns (uint256) {

        uint adder = 0;
        for (uint256 i = 0; i < votes[_id].voters.length; i++) {
            if (votes[_id].voters[i].vote == false) {
                adder += balanceOf(votes[_id].voters[i].id);
            }
        }
        return adder;
    }
}