
pragma solidity 0.4.25;


interface IContractAddressLocator {

    function getContractAddress(bytes32 _identifier) external view returns (address);


    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);

}


contract ContractAddressLocatorHolder {

    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _ISogurExchanger_           = "ISogurExchanger"          ;
    bytes32 internal constant _SgnToSgrExchangeInitiator_ = "SgnToSgrExchangeInitiator"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGRAuthorizationManager_ = "ISGRAuthorizationManager";
    bytes32 internal constant _ISGRToken_                = "ISGRToken"               ;
    bytes32 internal constant _ISGRTokenManager_         = "ISGRTokenManager"        ;
    bytes32 internal constant _ISGRTokenInfo_         = "ISGRTokenInfo"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGRTokenManager_          = "BuyWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGRTokenManager_          = "SellWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;
    bytes32 internal constant _SGAToSGRInitializer_      = "SGAToSGRInitializer"     ;

    IContractAddressLocator private contractAddressLocator;

    constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

    function getContractAddressLocator() external view returns (IContractAddressLocator) {

        return contractAddressLocator;
    }

    function getContractAddress(bytes32 _identifier) internal view returns (address) {

        return contractAddressLocator.getContractAddress(_identifier);
    }



    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {

        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

    modifier only(bytes32 _identifier) {

        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}


interface ISGRAuthorizationManager {

    function isAuthorizedToBuy(address _sender) external view returns (bool);


    function isAuthorizedToSell(address _sender) external view returns (bool);


    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);


    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);


    function isAuthorizedForPublicOperation(address _sender) external view returns (bool);

}


contract ProposalVoting is ContractAddressLocatorHolder {

    string public constant VERSION = "1.0.0";

    string public description;

    uint256 public choicesCount;

    mapping(address => uint256) public votes;

    address[] public voters;

    uint256 public startBlock;
    uint256 public endBlock;

    event ProposalVoteCasted(address indexed voter, uint256 choice);

    constructor(IContractAddressLocator _contractAddressLocator, string _description, uint256 _startBlock, uint256 _endBlock, uint256 _choicesCount) ContractAddressLocatorHolder(_contractAddressLocator) public
    {

        require(_startBlock > block.number, "invalid start block");
        require(_endBlock > _startBlock, "invalid end block");
        require(_choicesCount <= 4, "invalid choices count");

        bytes memory _bytes = bytes(_description);
        require(_bytes.length != 0, "invalid empty description");

        description = _description;

        startBlock = _startBlock;
        endBlock = _endBlock;

        choicesCount = _choicesCount;
    }

    function getSGRAuthorizationManager() public view returns (ISGRAuthorizationManager) {

        return ISGRAuthorizationManager(getContractAddress(_ISGRAuthorizationManager_));
    }

    modifier onlyIfActive() {

        require(isActive(), "voting proposal not active");
        _;
    }


    modifier onlyIfUserVoteAbsent() {

        require(votes[msg.sender] == 0, "voting proposal already voted");
        _;
    }

    modifier onlyIfValidChoiceIndex(uint256 _choiceIndex) {

        require(_choiceIndex < choicesCount, "invalid voting choice index");
        _;
    }


    modifier onlyIfAuthorizedUser() {

        ISGRAuthorizationManager sgrAuthorizationManager = getSGRAuthorizationManager();
        bool senderIsAuthorized = sgrAuthorizationManager.isAuthorizedForPublicOperation(msg.sender);
        require(senderIsAuthorized, "user is not authorized");
        _;
    }

    function isActive() public view returns (bool) {

        uint256 currentBlockNumber = block.number;
        return currentBlockNumber >= startBlock && currentBlockNumber <= endBlock;
    }

    function getTotalVoters() external view returns (uint256) {

        return voters.length;
    }

    function getVotersRange(uint256 _startIndex, uint256 _count) external view returns (address[] memory) {

        uint256 rangeCount = _count;
        if (rangeCount > voters.length - _startIndex) {
            rangeCount = voters.length - _startIndex;
        }
        address[] memory rangeVoters = new address[](rangeCount);

        for (uint256 i = 0; i < rangeCount; i++) {
            rangeVoters[i] = voters[_startIndex + i];
        }

        return rangeVoters;
    }

    function getAllVoters() external view returns (address[] memory) {

        return voters;
    }


    function castVote(uint256 _choiceIndex) internal onlyIfActive onlyIfUserVoteAbsent onlyIfValidChoiceIndex(_choiceIndex) onlyIfAuthorizedUser
    {

        uint256 base1ChoiceIndex = _choiceIndex + 1;
        address sender = msg.sender;
        votes[sender] = base1ChoiceIndex;
        voters.push(sender);
        emit ProposalVoteCasted(sender, base1ChoiceIndex);
    }
}


contract ReservePortionRNBAlternativeProposalVoting is ProposalVoting {


    string[4] public choices = ["USD", "EUR", "GBP", "JPY"];

    constructor(IContractAddressLocator _contractAddressLocator) ProposalVoting(_contractAddressLocator, "Vote on temporary alternative currency for holding of reserve RNB", 11372645, 11412214, 4) public {}

    function voteUSD() public
    {

        castVote(0);
    }

    function voteEUR() public
    {

        castVote(1);
    }

    function voteGBP() public
    {

        castVote(2);
    }

    function voteJPY() public
    {

        castVote(3);
    }
}