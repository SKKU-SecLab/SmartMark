



pragma solidity ^0.5.0;

library SafeBitMath {


    function safe64(uint n, string memory errorMessage) internal pure returns (uint64) {

        require(n < 2 ** 64, errorMessage);
        return uint64(n);
    }

    function safe128(uint n, string memory errorMessage) internal pure returns (uint128) {

        require(n < 2 ** 128, errorMessage);
        return uint128(n);
    }

    function add128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add128(uint128 a, uint128 b) internal pure returns (uint128) {

        return add128(a, b, "");
    }

    function sub128(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {

        return sub128(a, b, "");
    }

}


pragma solidity >=0.4.24 <0.7.0;


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




pragma solidity ^0.5.0;


contract IOwnableOrGuardian is Initializable {



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);


    modifier onlyOwnerOrGuardian {

        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {

        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }

    address internal _owner;
    address internal _guardian;


    function owner() external view returns (address) {

        return _owner;
    }

    function guardian() external view returns (address) {

        return _guardian;
    }


    function initialize(
        address __owner,
        address __guardian
    )
    public
    initializer {

        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function transferOwnership(
        address __owner
    )
    public
    onlyOwner {

        require(
            __owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(__owner);
    }

    function renounceOwnership() public onlyOwner {

        _transferOwnership(address(0));
    }

    function transferGuardian(
        address __guardian
    )
    public
    onlyOwner {

        require(
            __guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(__guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {

        _transferGuardian(address(0));
    }


    function _transferOwnership(
        address __owner
    )
    internal {

        address previousOwner = _owner;
        _owner = __owner;
        emit OwnershipTransferred(previousOwner, __owner);
    }

    function _transferGuardian(
        address __guardian
    )
    internal {

        address previousGuardian = _guardian;
        _guardian = __guardian;
        emit GuardianTransferred(previousGuardian, __guardian);
    }

}




pragma solidity ^0.5.13;

interface IDMGToken {


    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    function getPriorVotes(address account, uint blockNumber) external view returns (uint128);


    function getCurrentVotes(address account) external view returns (uint128);


    function delegates(address delegator) external view returns (address);


    function burn(uint amount) external returns (bool);


    function approveBySig(
        address spender,
        uint rawAmount,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


}




pragma solidity ^0.5.0;




contract AssetIntroducerData is Initializable, IOwnableOrGuardian {




    uint64 internal _guardCounter;

    AssetIntroducerStateV1 internal _assetIntroducerStateV1;

    ERC721StateV1 internal _erc721StateV1;

    VoteStateV1 internal _voteStateV1;


    enum AssetIntroducerType {
        PRINCIPAL, AFFILIATE
    }

    struct AssetIntroducerStateV1 {
        uint64 initTimestamp;

        bool isDmmFoundationSetup;

        uint128 totalDmgLocked;

        bytes32 domainSeparator;

        address dmg;

        address dmmController;

        address underlyingTokenValuator;

        address assetIntroducerDiscount;

        address stakingPurchaser;

        mapping(uint => AssetIntroducer) idToAssetIntroducer;

        mapping(bytes3 => mapping(uint8 => uint[])) countryCodeToAssetIntroducerTypeToTokenIdsMap;

        mapping(bytes3 => mapping(uint8 => uint96)) countryCodeToAssetIntroducerTypeToPriceUsd;

        mapping(uint => mapping(address => uint)) tokenIdToUnderlyingTokenToWithdrawnAmount;

        mapping(address => uint) ownerToNonceMap;
    }

    struct ERC721StateV1 {
        uint64 totalSupply;

        address openSeaProxyRegistry;

        uint lastTokenId;

        string baseURI;

        mapping(uint => uint) allTokens;

        mapping(uint256 => address) idToOwnerMap;

        mapping(uint256 => address) idToSpenderMap;

        mapping(address => mapping(address => bool)) ownerToOperatorToIsApprovedMap;

        mapping(address => mapping(uint => uint)) ownerToTokenIds;

        mapping(address => uint32) ownerToTokenCount;

        mapping(bytes4 => bool) interfaceIdToIsSupportedMap;
    }

    struct VoteStateV1 {
        mapping(address => mapping(uint64 => Checkpoint)) ownerToCheckpointIndexToCheckpointMap;
        mapping(address => uint64) ownerToCheckpointCountMap;
    }

    struct AssetIntroducer {
        bytes3 countryCode;
        AssetIntroducerType introducerType;
        bool isOnSecondaryMarket;
        bool isAllowedToWithdrawFunds;
        uint16 serialNumber;
        uint96 dmgLocked;
        uint96 dollarAmountToManage;
        uint tokenId;
    }

    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    struct DmgApprovalStruct {
        address spender;
        uint rawAmount;
        uint nonce;
        uint expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DiscountStruct {
        uint64 initTimestamp;
    }


    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }

    modifier requireIsPrimaryMarketNft(uint __tokenId) {

        require(
            !_assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_SECONDARY_MARKET"
        );

        _;
    }

    modifier requireIsSecondaryMarketNft(uint __tokenId) {

        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_PRIMARY_MARKET"
        );

        _;
    }

    modifier requireIsValidNft(uint __tokenId) {

        require(
            _erc721StateV1.idToOwnerMap[__tokenId] != address(0),
            "AssetIntroducerData: INVALID_NFT"
        );

        _;
    }

    modifier requireIsNftOwner(uint __tokenId) {

        require(
            _erc721StateV1.idToOwnerMap[__tokenId] == msg.sender,
            "AssetIntroducerData: INVALID_NFT_OWNER"
        );

        _;
    }

    modifier requireCanWithdrawFunds(uint __tokenId) {

        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isAllowedToWithdrawFunds,
            "AssetIntroducerData: NFT_NOT_ACTIVATED"
        );

        _;
    }

    modifier requireIsStakingPurchaser() {

        require(
            _assetIntroducerStateV1.stakingPurchaser != address(0),
            "AssetIntroducerData: STAKING_PURCHASER_NOT_SETUP"
        );

        require(
            _assetIntroducerStateV1.stakingPurchaser == msg.sender,
            "AssetIntroducerData: INVALID_SENDER_FOR_STAKING"
        );
        _;
    }

}




pragma solidity ^0.5.0;



library AssetIntroducerVotingLib {



    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    function getCurrentVotes(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner
    ) public view returns (uint) {

        uint64 checkpointCount = __state.ownerToCheckpointCountMap[__owner];
        return checkpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].votes : 0;
    }

    function getPriorVotes(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner,
        uint __blockNumber
    ) public view returns (uint128) {

        require(
            __blockNumber < block.number,
            "AssetIntroducerVotingLib::getPriorVotes: not yet determined"
        );

        uint64 checkpointCount = __state.ownerToCheckpointCountMap[__owner];
        if (checkpointCount == 0) {
            return 0;
        }

        if (__state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].fromBlock <= __blockNumber) {
            return __state.ownerToCheckpointIndexToCheckpointMap[__owner][checkpointCount - 1].votes;
        }

        if (__state.ownerToCheckpointIndexToCheckpointMap[__owner][0].fromBlock > __blockNumber) {
            return 0;
        }

        uint64 lower = 0;
        uint64 upper = checkpointCount - 1;
        while (upper > lower) {
            uint64 center = upper - (upper - lower) / 2;
            AssetIntroducerData.Checkpoint memory checkpoint = __state.ownerToCheckpointIndexToCheckpointMap[__owner][center];
            if (checkpoint.fromBlock == __blockNumber) {
                return checkpoint.votes;
            } else if (checkpoint.fromBlock < __blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return __state.ownerToCheckpointIndexToCheckpointMap[__owner][lower].votes;
    }

    function moveDelegates(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __fromOwner,
        address __toOwner,
        uint128 __amount
    ) public {

        if (__fromOwner != __toOwner && __amount > 0) {
            if (__fromOwner != address(0)) {
                uint64 fromCheckpointCount = __state.ownerToCheckpointCountMap[__fromOwner];
                uint128 fromVotesOld = fromCheckpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__fromOwner][fromCheckpointCount - 1].votes : 0;
                uint128 fromVotesNew = SafeBitMath.sub128(
                    fromVotesOld,
                    __amount,
                    "AssetIntroducerVotingLib::moveDelegates: VOTE_UNDERFLOW"
                );
                _writeCheckpoint(__state, __fromOwner, fromCheckpointCount, fromVotesOld, fromVotesNew);
            }

            if (__toOwner != address(0)) {
                uint64 toCheckpointCount = __state.ownerToCheckpointCountMap[__toOwner];
                uint128 toVotesOld = toCheckpointCount > 0 ? __state.ownerToCheckpointIndexToCheckpointMap[__toOwner][toCheckpointCount - 1].votes : 0;
                uint128 toVotesNew = SafeBitMath.add128(
                    toVotesOld,
                    __amount,
                    "AssetIntroducerVotingLib::moveDelegates: VOTE_OVERFLOW"
                );
                _writeCheckpoint(__state, __toOwner, toCheckpointCount, toVotesOld, toVotesNew);
            }
        }
    }


    function _writeCheckpoint(
        AssetIntroducerData.VoteStateV1 storage __state,
        address __owner,
        uint64 __checkpointCount,
        uint128 __oldVotes,
        uint128 __newVotes
    ) internal {

        uint64 blockNumber = SafeBitMath.safe64(
            block.number,
            "AssetIntroducerVotingLib::_writeCheckpoint: INVALID_BLOCK_NUMBER"
        );

        if (__checkpointCount > 0 && __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount - 1].fromBlock == blockNumber) {
            __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount - 1].votes = __newVotes;
        } else {
            __state.ownerToCheckpointIndexToCheckpointMap[__owner][__checkpointCount] = AssetIntroducerData.Checkpoint(blockNumber, __newVotes);
            __state.ownerToCheckpointCountMap[__owner] = __checkpointCount + 1;
        }

        emit DelegateVotesChanged(__owner, __oldVotes, __newVotes);
    }

}