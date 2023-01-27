pragma solidity 0.5.15;

contract IAugur {

    function createChildUniverse(bytes32 _parentPayoutDistributionHash, uint256[] memory _parentPayoutNumerators) public returns (IUniverse);

    function isKnownUniverse(IUniverse _universe) public view returns (bool);

    function trustedCashTransfer(address _from, address _to, uint256 _amount) public returns (bool);

    function isTrustedSender(address _address) public returns (bool);

    function onCategoricalMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, bytes32[] memory _outcomes) public returns (bool);

    function onYesNoMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash) public returns (bool);

    function onScalarMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, int256[] memory _prices, uint256 _numTicks)  public returns (bool);

    function logInitialReportSubmitted(IUniverse _universe, address _reporter, address _market, address _initialReporter, uint256 _amountStaked, bool _isDesignatedReporter, uint256[] memory _payoutNumerators, string memory _description, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime) public returns (bool);

    function disputeCrowdsourcerCreated(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _size, uint256 _disputeRound) public returns (bool);

    function logDisputeCrowdsourcerContribution(IUniverse _universe, address _reporter, address _market, address _disputeCrowdsourcer, uint256 _amountStaked, string memory description, uint256[] memory _payoutNumerators, uint256 _currentStake, uint256 _stakeRemaining, uint256 _disputeRound) public returns (bool);

    function logDisputeCrowdsourcerCompleted(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime, bool _pacingOn, uint256 _totalRepStakedInPayout, uint256 _totalRepStakedInMarket, uint256 _disputeRound) public returns (bool);

    function logInitialReporterRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);

    function logDisputeCrowdsourcerRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);

    function logMarketFinalized(IUniverse _universe, uint256[] memory _winningPayoutNumerators) public returns (bool);

    function logMarketMigrated(IMarket _market, IUniverse _originalUniverse) public returns (bool);

    function logReportingParticipantDisavowed(IUniverse _universe, IMarket _market) public returns (bool);

    function logMarketParticipantsDisavowed(IUniverse _universe) public returns (bool);

    function logCompleteSetsPurchased(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets) public returns (bool);

    function logCompleteSetsSold(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets, uint256 _fees) public returns (bool);

    function logMarketOIChanged(IUniverse _universe, IMarket _market) public returns (bool);

    function logTradingProceedsClaimed(IUniverse _universe, address _sender, address _market, uint256 _outcome, uint256 _numShares, uint256 _numPayoutTokens, uint256 _fees) public returns (bool);

    function logUniverseForked(IMarket _forkingMarket) public returns (bool);

    function logReputationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);

    function logReputationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logReputationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logShareTokensBalanceChanged(address _account, IMarket _market, uint256 _outcome, uint256 _balance) public returns (bool);

    function logDisputeCrowdsourcerTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);

    function logDisputeCrowdsourcerTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logDisputeCrowdsourcerTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logDisputeWindowCreated(IDisputeWindow _disputeWindow, uint256 _id, bool _initial) public returns (bool);

    function logParticipationTokensRedeemed(IUniverse universe, address _sender, uint256 _attoParticipationTokens, uint256 _feePayoutShare) public returns (bool);

    function logTimestampSet(uint256 _newTimestamp) public returns (bool);

    function logInitialReporterTransferred(IUniverse _universe, IMarket _market, address _from, address _to) public returns (bool);

    function logMarketTransferred(IUniverse _universe, address _from, address _to) public returns (bool);

    function logParticipationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);

    function logParticipationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logParticipationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);

    function logMarketRepBondTransferred(address _universe, address _from, address _to) public returns (bool);

    function logWarpSyncDataUpdated(address _universe, uint256 _warpSyncHash, uint256 _marketEndTime) public returns (bool);

    function isKnownFeeSender(address _feeSender) public view returns (bool);

    function lookup(bytes32 _key) public view returns (address);

    function getTimestamp() public view returns (uint256);

    function getMaximumMarketEndDate() public returns (uint256);

    function isKnownMarket(IMarket _market) public view returns (bool);

    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators, uint256 _numTicks, uint256 numOutcomes) public view returns (bytes32);

    function logValidityBondChanged(uint256 _validityBond) public returns (bool);

    function logDesignatedReportStakeChanged(uint256 _designatedReportStake) public returns (bool);

    function logNoShowBondChanged(uint256 _noShowBond) public returns (bool);

    function logReportingFeeChanged(uint256 _reportingFee) public returns (bool);

    function getUniverseForkIndex(IUniverse _universe) public view returns (uint256);

}

library ContractExists {

    function exists(address _address) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract IOwnable {

    function getOwner() public view returns (address);

    function transferOwnership(address _newOwner) public returns (bool);

}

contract ITyped {

    function getTypeName() public view returns (bytes32);

}

contract Initializable {

    bool private initialized = false;

    modifier beforeInitialized {

        require(!initialized);
        _;
    }

    function endInitialization() internal beforeInitialized {

        initialized = true;
    }

    function getInitialized() public view returns (bool) {

        return initialized;
    }
}

contract ReentrancyGuard {

    bool private rentrancyLock = false;

    modifier nonReentrant() {

        require(!rentrancyLock);
        rentrancyLock = true;
        _;
        rentrancyLock = false;
    }
}

library TokenId {


    function getTokenId(IMarket _market, uint256 _outcome) internal pure returns (uint256 _tokenId) {

        bytes memory _tokenIdBytes = abi.encodePacked(_market, uint8(_outcome));
        assembly {
            _tokenId := mload(add(_tokenIdBytes, add(0x20, 0)))
        }
    }

    function getTokenIds(IMarket _market, uint256[] memory _outcomes) internal pure returns (uint256[] memory _tokenIds) {

        _tokenIds = new uint256[](_outcomes.length);
        for (uint256 _i = 0; _i < _outcomes.length; _i++) {
            _tokenIds[_i] = getTokenId(_market, _outcomes[_i]);
        }
    }

    function unpackTokenId(uint256 _tokenId) internal pure returns (address _market, uint256 _outcome) {

        assembly {
            _market := shr(96,  and(_tokenId, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000))
            _outcome := shr(88, and(_tokenId, 0x0000000000000000000000000000000000000000FF0000000000000000000000))
        }
    }
}

library SafeMathUint256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            uint256 x = (y + 1) / 2;
            z = y;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getUint256Min() internal pure returns (uint256) {

        return 0;
    }

    function getUint256Max() internal pure returns (uint256) {

        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function isMultipleOf(uint256 a, uint256 b) internal pure returns (bool) {

        return a % b == 0;
    }

    function fxpMul(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {

        return div(mul(a, b), base);
    }

    function fxpDiv(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {

        return div(mul(a, base), b);
    }
}

interface IERC1155 {


    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(
        string value,
        uint256 indexed id
    );

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external;


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function balanceOf(address owner, uint256 id) external view returns (uint256);


    function totalSupply(uint256 id) external view returns (uint256);


    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    )
        external
        view
        returns (uint256[] memory balances_);

}

contract ERC1155 is ERC165, IERC1155 {

    using SafeMathUint256 for uint256;
    using ContractExists for address;

    mapping (uint256 => mapping(address => uint256)) public _balances;

    mapping (uint256 => uint256) public _supplys;

    mapping (address => mapping(address => bool)) public _operatorApprovals;

    constructor()
        public
    {
        _registerInterface(
            ERC1155(0).safeTransferFrom.selector ^
            ERC1155(0).safeBatchTransferFrom.selector ^
            ERC1155(0).balanceOf.selector ^
            ERC1155(0).balanceOfBatch.selector ^
            ERC1155(0).setApprovalForAll.selector ^
            ERC1155(0).isApprovedForAll.selector
        );
    }

    function balanceOf(address account, uint256 id) public view returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function totalSupply(uint256 id) public view returns (uint256) {

        return _supplys[id];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and IDs must have same lengths");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: some address in batch balance query is zero");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external {

        require(msg.sender != operator, "ERC1155: cannot set approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view returns (bool) {

        return operator == address(this) || _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
    {

        _transferFrom(from, to, id, value, data, true);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool doAcceptanceCheck
    )
        internal
    {

        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        _internalTransferFrom(from, to, id, value, data, doAcceptanceCheck);
    }

    function _internalTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool doAcceptanceCheck
    )
        internal
    {

        _balances[id][from] = _balances[id][from].sub(value);
        _balances[id][to] = _balances[id][to].add(value);

        onTokenTransfer(id, from, to, value);
        emit TransferSingle(msg.sender, from, to, id, value);

        if (doAcceptanceCheck) {
            _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
    {

        _batchTransferFrom(from, to, ids, values, data, true);
    }

    function _batchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data,
        bool doAcceptanceCheck
    )
        internal
    {

        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");
        if (ids.length == 0) {
            return;
        }
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        _internalBatchTransferFrom(from, to, ids, values, data, doAcceptanceCheck);
    }

    function _internalBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data,
        bool doAcceptanceCheck
    )
        internal
    {

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[id][from] = _balances[id][from].sub(value);
            _balances[id][to] = _balances[id][to].add(value);
            onTokenTransfer(id, from, to, value);
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        if (doAcceptanceCheck) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
        }
    }

    function _mint(address to, uint256 id, uint256 value, bytes memory data, bool doAcceptanceCheck) internal {

        require(to != address(0), "ERC1155: mint to the zero address");

        _balances[id][to] = _balances[id][to].add(value);
        _supplys[id] = _supplys[id].add(value);

        onMint(id, to, value);
        emit TransferSingle(msg.sender, address(0), to, id, value);

        if (doAcceptanceCheck) {
            _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, value, data);
        }
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data, bool doAcceptanceCheck) internal {

        require(to != address(0), "ERC1155: batch mint to the zero address");
        require(ids.length == values.length, "ERC1155: minted IDs and values must have same lengths");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = values[i].add(_balances[ids[i]][to]);
            _supplys[ids[i]] = _supplys[ids[i]].add(values[i]);
            onMint(ids[i], to, values[i]);
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        if (doAcceptanceCheck) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, values, data);
        }
    }

    function _burn(address account, uint256 id, uint256 value, bytes memory data, bool doAcceptanceCheck) internal {

        require(account != address(0), "ERC1155: attempting to burn tokens on zero account");

        _balances[id][account] = _balances[id][account].sub(value);
        _supplys[id] = _supplys[id].sub(value);
        onBurn(id, account, value);
        emit TransferSingle(msg.sender, account, address(0), id, value);

        if (doAcceptanceCheck) {
            _doSafeTransferAcceptanceCheck(msg.sender, account, address(0), id, value, data);
        }
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory values, bytes memory data, bool doAcceptanceCheck) internal {

        require(account != address(0), "ERC1155: attempting to burn batch of tokens on zero account");
        require(ids.length == values.length, "ERC1155: burnt IDs and values must have same lengths");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(values[i]);
            _supplys[ids[i]] = _supplys[ids[i]].sub(values[i]);
            onBurn(ids[i], account, values[i]);
        }

        emit TransferBatch(msg.sender, account, address(0), ids, values);

        if (doAcceptanceCheck) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, account, address(0), ids, values, data);
        }
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    )
        internal
    {

        if (to.exists()) {
            require(
                IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) ==
                    IERC1155Receiver(to).onERC1155Received.selector,
                "ERC1155: got unknown value from onERC1155Received"
            );
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    )
        internal
    {

        if (to.exists()) {
            require(
                IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) ==
                    IERC1155Receiver(to).onERC1155BatchReceived.selector,
                "ERC1155: got unknown value from onERC1155BatchReceived"
            );
        }
    }

    function onTokenTransfer(uint256 _tokenId, address _from, address _to, uint256 _value) internal;


    function onMint(uint256 _tokenId, address _target, uint256 _amount) internal;


    function onBurn(uint256 _tokenId, address _target, uint256 _amount) internal;

}

contract IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

contract IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) public view returns (uint256);

    function transfer(address to, uint256 amount) public returns (bool);

    function transferFrom(address from, address to, uint256 amount) public returns (bool);

    function approve(address spender, uint256 amount) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ICash is IERC20 {

}

contract IAffiliateValidator {

    function validateReference(address _account, address _referrer) external view returns (bool);

}

contract IDisputeWindow is ITyped, IERC20 {

    function invalidMarketsTotal() external view returns (uint256);

    function validityBondTotal() external view returns (uint256);


    function incorrectDesignatedReportTotal() external view returns (uint256);

    function initialReportBondTotal() external view returns (uint256);


    function designatedReportNoShowsTotal() external view returns (uint256);

    function designatedReporterNoShowBondTotal() external view returns (uint256);


    function initialize(IAugur _augur, IUniverse _universe, uint256 _disputeWindowId, bool _participationTokensEnabled, uint256 _duration, uint256 _startTime) public;

    function trustedBuy(address _buyer, uint256 _attotokens) public returns (bool);

    function getUniverse() public view returns (IUniverse);

    function getReputationToken() public view returns (IReputationToken);

    function getStartTime() public view returns (uint256);

    function getEndTime() public view returns (uint256);

    function getWindowId() public view returns (uint256);

    function isActive() public view returns (bool);

    function isOver() public view returns (bool);

    function onMarketFinalized() public;

    function redeem(address _account) public returns (bool);

}

contract IMarket is IOwnable {

    enum MarketType {
        YES_NO,
        CATEGORICAL,
        SCALAR
    }

    function initialize(IAugur _augur, IUniverse _universe, uint256 _endTime, uint256 _feePerCashInAttoCash, IAffiliateValidator _affiliateValidator, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, address _creator, uint256 _numOutcomes, uint256 _numTicks) public;

    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators) public view returns (bytes32);

    function doInitialReport(uint256[] memory _payoutNumerators, string memory _description, uint256 _additionalStake) public returns (bool);

    function getUniverse() public view returns (IUniverse);

    function getDisputeWindow() public view returns (IDisputeWindow);

    function getNumberOfOutcomes() public view returns (uint256);

    function getNumTicks() public view returns (uint256);

    function getMarketCreatorSettlementFeeDivisor() public view returns (uint256);

    function getForkingMarket() public view returns (IMarket _market);

    function getEndTime() public view returns (uint256);

    function getWinningPayoutDistributionHash() public view returns (bytes32);

    function getWinningPayoutNumerator(uint256 _outcome) public view returns (uint256);

    function getWinningReportingParticipant() public view returns (IReportingParticipant);

    function getReputationToken() public view returns (IV2ReputationToken);

    function getFinalizationTime() public view returns (uint256);

    function getInitialReporter() public view returns (IInitialReporter);

    function getDesignatedReportingEndTime() public view returns (uint256);

    function getValidityBondAttoCash() public view returns (uint256);

    function affiliateFeeDivisor() external view returns (uint256);

    function getNumParticipants() public view returns (uint256);

    function getDisputePacingOn() public view returns (bool);

    function deriveMarketCreatorFeeAmount(uint256 _amount) public view returns (uint256);

    function recordMarketCreatorFees(uint256 _marketCreatorFees, address _sourceAccount, bytes32 _fingerprint) public returns (bool);

    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);

    function isFinalizedAsInvalid() public view returns (bool);

    function finalize() public returns (bool);

    function isFinalized() public view returns (bool);

    function getOpenInterest() public view returns (uint256);

}

contract IReportingParticipant {

    function getStake() public view returns (uint256);

    function getPayoutDistributionHash() public view returns (bytes32);

    function liquidateLosing() public;

    function redeem(address _redeemer) public returns (bool);

    function isDisavowed() public view returns (bool);

    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);

    function getPayoutNumerators() public view returns (uint256[] memory);

    function getMarket() public view returns (IMarket);

    function getSize() public view returns (uint256);

}

contract IInitialReporter is IReportingParticipant, IOwnable {

    function initialize(IAugur _augur, IMarket _market, address _designatedReporter) public;

    function report(address _reporter, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, uint256 _initialReportStake) public;

    function designatedReporterShowed() public view returns (bool);

    function initialReporterWasCorrect() public view returns (bool);

    function getDesignatedReporter() public view returns (address);

    function getReportTimestamp() public view returns (uint256);

    function migrateToNewUniverse(address _designatedReporter) public;

    function returnRepFromDisavow() public;

}

contract IReputationToken is IERC20 {

    function migrateOutByPayout(uint256[] memory _payoutNumerators, uint256 _attotokens) public returns (bool);

    function migrateIn(address _reporter, uint256 _attotokens) public returns (bool);

    function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);

    function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);

    function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);

    function trustedDisputeWindowTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);

    function getUniverse() public view returns (IUniverse);

    function getTotalMigrated() public view returns (uint256);

    function getTotalTheoreticalSupply() public view returns (uint256);

    function mintForReportingParticipant(uint256 _amountMigrated) public returns (bool);

}

contract IShareToken is ITyped, IERC1155 {

    function initialize(IAugur _augur) external;

    function initializeMarket(IMarket _market, uint256 _numOutcomes, uint256 _numTicks) public;

    function unsafeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) public;

    function unsafeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values) public;

    function claimTradingProceeds(IMarket _market, address _shareHolder, bytes32 _fingerprint) external returns (uint256[] memory _outcomeFees);

    function getMarket(uint256 _tokenId) external view returns (IMarket);

    function getOutcome(uint256 _tokenId) external view returns (uint256);

    function getTokenId(IMarket _market, uint256 _outcome) public pure returns (uint256 _tokenId);

    function getTokenIds(IMarket _market, uint256[] memory _outcomes) public pure returns (uint256[] memory _tokenIds);

    function buyCompleteSets(IMarket _market, address _account, uint256 _amount) external returns (bool);

    function buyCompleteSetsForTrade(IMarket _market, uint256 _amount, uint256 _longOutcome, address _longRecipient, address _shortRecipient) external returns (bool);

    function sellCompleteSets(IMarket _market, address _holder, address _recipient, uint256 _amount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee);

    function sellCompleteSetsForTrade(IMarket _market, uint256 _outcome, uint256 _amount, address _shortParticipant, address _longParticipant, address _shortRecipient, address _longRecipient, uint256 _price, address _sourceAccount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee);

    function totalSupplyForMarketOutcome(IMarket _market, uint256 _outcome) public view returns (uint256);

    function balanceOfMarketOutcome(IMarket _market, uint256 _outcome, address _account) public view returns (uint256);

    function lowestBalanceOfMarketOutcomes(IMarket _market, uint256[] memory _outcomes, address _account) public view returns (uint256);

}

contract IUniverse {

    function creationTime() external view returns (uint256);

    function marketBalance(address) external view returns (uint256);


    function fork() public returns (bool);

    function updateForkValues() public returns (bool);

    function getParentUniverse() public view returns (IUniverse);

    function createChildUniverse(uint256[] memory _parentPayoutNumerators) public returns (IUniverse);

    function getChildUniverse(bytes32 _parentPayoutDistributionHash) public view returns (IUniverse);

    function getReputationToken() public view returns (IV2ReputationToken);

    function getForkingMarket() public view returns (IMarket);

    function getForkEndTime() public view returns (uint256);

    function getForkReputationGoal() public view returns (uint256);

    function getParentPayoutDistributionHash() public view returns (bytes32);

    function getDisputeRoundDurationInSeconds(bool _initial) public view returns (uint256);

    function getOrCreateDisputeWindowByTimestamp(uint256 _timestamp, bool _initial) public returns (IDisputeWindow);

    function getOrCreateCurrentDisputeWindow(bool _initial) public returns (IDisputeWindow);

    function getOrCreateNextDisputeWindow(bool _initial) public returns (IDisputeWindow);

    function getOrCreatePreviousDisputeWindow(bool _initial) public returns (IDisputeWindow);

    function getOpenInterestInAttoCash() public view returns (uint256);

    function getTargetRepMarketCapInAttoCash() public view returns (uint256);

    function getOrCacheValidityBond() public returns (uint256);

    function getOrCacheDesignatedReportStake() public returns (uint256);

    function getOrCacheDesignatedReportNoShowBond() public returns (uint256);

    function getOrCacheMarketRepBond() public returns (uint256);

    function getOrCacheReportingFeeDivisor() public returns (uint256);

    function getDisputeThresholdForFork() public view returns (uint256);

    function getDisputeThresholdForDisputePacing() public view returns (uint256);

    function getInitialReportMinValue() public view returns (uint256);

    function getPayoutNumerators() public view returns (uint256[] memory);

    function getReportingFeeDivisor() public view returns (uint256);

    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);

    function getWinningChildPayoutNumerator(uint256 _outcome) public view returns (uint256);

    function isOpenInterestCash(address) public view returns (bool);

    function isForkingMarket() public view returns (bool);

    function getCurrentDisputeWindow(bool _initial) public view returns (IDisputeWindow);

    function getDisputeWindowStartTimeAndDuration(uint256 _timestamp, bool _initial) public view returns (uint256, uint256);

    function isParentOf(IUniverse _shadyChild) public view returns (bool);

    function updateTentativeWinningChildUniverse(bytes32 _parentPayoutDistributionHash) public returns (bool);

    function isContainerForDisputeWindow(IDisputeWindow _shadyTarget) public view returns (bool);

    function isContainerForMarket(IMarket _shadyTarget) public view returns (bool);

    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);

    function migrateMarketOut(IUniverse _destinationUniverse) public returns (bool);

    function migrateMarketIn(IMarket _market, uint256 _cashBalance, uint256 _marketOI) public returns (bool);

    function decrementOpenInterest(uint256 _amount) public returns (bool);

    function decrementOpenInterestFromMarket(IMarket _market) public returns (bool);

    function incrementOpenInterest(uint256 _amount) public returns (bool);

    function getWinningChildUniverse() public view returns (IUniverse);

    function isForking() public view returns (bool);

    function deposit(address _sender, uint256 _amount, address _market) public returns (bool);

    function withdraw(address _recipient, uint256 _amount, address _market) public returns (bool);

    function createScalarMarket(uint256 _endTime, uint256 _feePerCashInAttoCash, IAffiliateValidator _affiliateValidator, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, int256[] memory _prices, uint256 _numTicks, string memory _extraInfo) public returns (IMarket _newMarket);

}

contract IV2ReputationToken is IReputationToken {

    function parentUniverse() external returns (IUniverse);

    function burnForMarket(uint256 _amountToBurn) public returns (bool);

    function mintForWarpSync(uint256 _amountToMint, address _target) public returns (bool);

}

contract IAugurTrading {

    function lookup(bytes32 _key) public view returns (address);

    function logProfitLossChanged(IMarket _market, address _account, uint256 _outcome, int256 _netPosition, uint256 _avgPrice, int256 _realizedProfit, int256 _frozenFunds, int256 _realizedCost) public returns (bool);

    function logOrderCreated(IUniverse _universe, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);

    function logOrderCanceled(IUniverse _universe, IMarket _market, address _creator, uint256 _tokenRefund, uint256 _sharesRefund, bytes32 _orderId) public returns (bool);

    function logOrderFilled(IUniverse _universe, address _creator, address _filler, uint256 _price, uint256 _fees, uint256 _amountFilled, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);

    function logMarketVolumeChanged(IUniverse _universe, address _market, uint256 _volume, uint256[] memory _outcomeVolumes, uint256 _totalTrades) public returns (bool);

    function logZeroXOrderFilled(IUniverse _universe, IMarket _market, bytes32 _orderHash, bytes32 _tradeGroupId, uint8 _orderType, address[] memory _addressData, uint256[] memory _uint256Data) public returns (bool);

    function logZeroXOrderCanceled(address _universe, address _market, address _account, uint256 _outcome, uint256 _price, uint256 _amount, uint8 _type, bytes32 _orderHash) public;

}

contract IOrders {

    function saveOrder(uint256[] calldata _uints, bytes32[] calldata _bytes32s, Order.Types _type, IMarket _market, address _sender) external returns (bytes32 _orderId);

    function removeOrder(bytes32 _orderId) external returns (bool);

    function getMarket(bytes32 _orderId) public view returns (IMarket);

    function getOrderType(bytes32 _orderId) public view returns (Order.Types);

    function getOutcome(bytes32 _orderId) public view returns (uint256);

    function getAmount(bytes32 _orderId) public view returns (uint256);

    function getPrice(bytes32 _orderId) public view returns (uint256);

    function getOrderCreator(bytes32 _orderId) public view returns (address);

    function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256);

    function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256);

    function getOrderDataForCancel(bytes32 _orderId) public view returns (uint256, uint256, Order.Types, IMarket, uint256, address);

    function getOrderDataForLogs(bytes32 _orderId) public view returns (Order.Types, address[] memory _addressData, uint256[] memory _uint256Data);

    function getBetterOrderId(bytes32 _orderId) public view returns (bytes32);

    function getWorseOrderId(bytes32 _orderId) public view returns (bytes32);

    function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);

    function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);

    function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256);

    function getOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed) public pure returns (bytes32);

    function getTotalEscrowed(IMarket _market) public view returns (uint256);

    function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);

    function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);

    function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool);

    function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool);

    function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled, uint256 _fill) external returns (bool);

    function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool);

}

library Order {

    using SafeMathUint256 for uint256;

    enum Types {
        Bid, Ask
    }

    enum TradeDirections {
        Long, Short
    }

    struct Data {
        IMarket market;
        IAugur augur;
        IAugurTrading augurTrading;
        IShareToken shareToken;
        ICash cash;

        bytes32 id;
        address creator;
        uint256 outcome;
        Order.Types orderType;
        uint256 amount;
        uint256 price;
        uint256 sharesEscrowed;
        uint256 moneyEscrowed;
        bytes32 betterOrderId;
        bytes32 worseOrderId;
    }

    function create(IAugur _augur, IAugurTrading _augurTrading, address _creator, uint256 _outcome, Order.Types _type, uint256 _attoshares, uint256 _price, IMarket _market, bytes32 _betterOrderId, bytes32 _worseOrderId) internal view returns (Data memory) {

        require(_outcome < _market.getNumberOfOutcomes(), "Order.create: Outcome is not within market range");
        require(_price != 0, "Order.create: Price may not be 0");
        require(_price < _market.getNumTicks(), "Order.create: Price is outside of market range");
        require(_attoshares > 0, "Order.create: Cannot use amount of 0");
        require(_creator != address(0), "Order.create: Creator is 0x0");

        IShareToken _shareToken = IShareToken(_augur.lookup("ShareToken"));

        return Data({
            market: _market,
            augur: _augur,
            augurTrading: _augurTrading,
            shareToken: _shareToken,
            cash: ICash(_augur.lookup("Cash")),
            id: 0,
            creator: _creator,
            outcome: _outcome,
            orderType: _type,
            amount: _attoshares,
            price: _price,
            sharesEscrowed: 0,
            moneyEscrowed: 0,
            betterOrderId: _betterOrderId,
            worseOrderId: _worseOrderId
        });
    }


    function getOrderId(Order.Data memory _orderData, IOrders _orders) internal view returns (bytes32) {

        if (_orderData.id == bytes32(0)) {
            bytes32 _orderId = calculateOrderId(_orderData.orderType, _orderData.market, _orderData.amount, _orderData.price, _orderData.creator, block.number, _orderData.outcome, _orderData.moneyEscrowed, _orderData.sharesEscrowed);
            require(_orders.getAmount(_orderId) == 0, "Order.getOrderId: New order had amount. This should not be possible");
            _orderData.id = _orderId;
        }
        return _orderData.id;
    }

    function calculateOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed) internal pure returns (bytes32) {

        return sha256(abi.encodePacked(_type, _market, _amount, _price, _sender, _blockNumber, _outcome, _moneyEscrowed, _sharesEscrowed));
    }

    function getOrderTradingTypeFromMakerDirection(Order.TradeDirections _creatorDirection) internal pure returns (Order.Types) {

        return (_creatorDirection == Order.TradeDirections.Long) ? Order.Types.Bid : Order.Types.Ask;
    }

    function getOrderTradingTypeFromFillerDirection(Order.TradeDirections _fillerDirection) internal pure returns (Order.Types) {

        return (_fillerDirection == Order.TradeDirections.Long) ? Order.Types.Ask : Order.Types.Bid;
    }

    function saveOrder(Order.Data memory _orderData, bytes32 _tradeGroupId, IOrders _orders) internal returns (bytes32) {

        getOrderId(_orderData, _orders);
        uint256[] memory _uints = new uint256[](5);
        _uints[0] = _orderData.amount;
        _uints[1] = _orderData.price;
        _uints[2] = _orderData.outcome;
        _uints[3] = _orderData.moneyEscrowed;
        _uints[4] = _orderData.sharesEscrowed;
        bytes32[] memory _bytes32s = new bytes32[](4);
        _bytes32s[0] = _orderData.betterOrderId;
        _bytes32s[1] = _orderData.worseOrderId;
        _bytes32s[2] = _tradeGroupId;
        _bytes32s[3] = _orderData.id;
        return _orders.saveOrder(_uints, _bytes32s, _orderData.orderType, _orderData.market, _orderData.creator);
    }
}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

contract ShareToken is ITyped, Initializable, ERC1155, IShareToken, ReentrancyGuard {


    string constant public name = "Shares";
    string constant public symbol = "SHARE";

    struct MarketData {
        uint256 numOutcomes;
        uint256 numTicks;
    }

    mapping(address => MarketData) markets;

    IAugur public augur;
    ICash public cash;

    function initialize(IAugur _augur) external beforeInitialized {

        endInitialization();
        augur = _augur;
        cash = ICash(_augur.lookup("Cash"));

        require(cash != ICash(0));
    }

    function unsafeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) public {

        _transferFrom(_from, _to, _id, _value, bytes(""), false);
    }

    function unsafeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values) public {

        _batchTransferFrom(_from, _to, _ids, _values, bytes(""), false);
    }

    function initializeMarket(IMarket _market, uint256 _numOutcomes, uint256 _numTicks) public {

        require (augur.isKnownUniverse(IUniverse(msg.sender)));
        markets[address(_market)].numOutcomes = _numOutcomes;
        markets[address(_market)].numTicks = _numTicks;
    }

    function publicBuyCompleteSets(IMarket _market, uint256 _amount) external returns (bool) {

        buyCompleteSetsInternal(_market, msg.sender, _amount);
        augur.logCompleteSetsPurchased(_market.getUniverse(), _market, msg.sender, _amount);
        return true;
    }

    function buyCompleteSets(IMarket _market, address _account, uint256 _amount) external returns (bool) {

        buyCompleteSetsInternal(_market, _account, _amount);
        return true;
    }

    function buyCompleteSetsInternal(IMarket _market, address _account, uint256 _amount) internal returns (bool) {

        uint256 _numOutcomes = markets[address(_market)].numOutcomes;
        uint256 _numTicks = markets[address(_market)].numTicks;

        require(_numOutcomes != 0, "Invalid Market provided");

        IUniverse _universe = _market.getUniverse();

        uint256 _cost = _amount.mul(_numTicks);
        _universe.deposit(msg.sender, _cost, address(_market));

        uint256[] memory _tokenIds = new uint256[](_numOutcomes);
        uint256[] memory _values = new uint256[](_numOutcomes);

        for (uint256 _i = 0; _i < _numOutcomes; _i++) {
            _tokenIds[_i] = TokenId.getTokenId(_market, _i);
            _values[_i] = _amount;
        }

        _mintBatch(_account, _tokenIds, _values, bytes(""), false);

        if (!_market.isFinalized()) {
            _universe.incrementOpenInterest(_cost);
        }

        augur.logMarketOIChanged(_universe, _market);

        assertBalances(_market);
        return true;
    }

    function buyCompleteSetsForTrade(IMarket _market, uint256 _amount, uint256 _longOutcome, address _longRecipient, address _shortRecipient) external returns (bool) {

        uint256 _numOutcomes = markets[address(_market)].numOutcomes;

        require(_numOutcomes != 0, "Invalid Market provided");
        require(_longOutcome < _numOutcomes);

        IUniverse _universe = _market.getUniverse();

        {
            uint256 _numTicks = markets[address(_market)].numTicks;
            uint256 _cost = _amount.mul(_numTicks);
            _universe.deposit(msg.sender, _cost, address(_market));

            if (!_market.isFinalized()) {
                _universe.incrementOpenInterest(_cost);
            }
        }

        uint256[] memory _tokenIds = new uint256[](_numOutcomes - 1);
        uint256[] memory _values = new uint256[](_numOutcomes - 1);
        uint256 _outcome = 0;

        for (uint256 _i = 0; _i < _numOutcomes - 1; _i++) {
            if (_outcome == _longOutcome) {
                _outcome++;
            }
            _tokenIds[_i] = TokenId.getTokenId(_market, _outcome);
            _values[_i] = _amount;
            _outcome++;
        }

        _mintBatch(_shortRecipient, _tokenIds, _values, bytes(""), false);
        _mint(_longRecipient, TokenId.getTokenId(_market, _longOutcome), _amount, bytes(""), false);

        augur.logMarketOIChanged(_universe, _market);

        assertBalances(_market);
        return true;
    }

    function publicSellCompleteSets(IMarket _market, uint256 _amount) external returns (uint256 _creatorFee, uint256 _reportingFee) {

        (uint256 _payout, uint256 _creatorFee, uint256 _reportingFee) = burnCompleteSets(_market, msg.sender, _amount, msg.sender, bytes32(0));

        require(cash.transfer(msg.sender, _payout));

        IUniverse _universe = _market.getUniverse();
        augur.logCompleteSetsSold(_universe, _market, msg.sender, _amount, _creatorFee.add(_reportingFee));

        assertBalances(_market);
        return (_creatorFee, _reportingFee);
    }

    function sellCompleteSets(IMarket _market, address _holder, address _recipient, uint256 _amount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee) {

        require(_holder == msg.sender || isApprovedForAll(_holder, msg.sender) == true, "ERC1155: need operator approval to sell complete sets");
        
        (uint256 _payout, uint256 _creatorFee, uint256 _reportingFee) = burnCompleteSets(_market, _holder, _amount, _holder, _fingerprint);

        require(cash.transfer(_recipient, _payout));

        assertBalances(_market);
        return (_creatorFee, _reportingFee);
    }

    function sellCompleteSetsForTrade(IMarket _market, uint256 _outcome, uint256 _amount, address _shortParticipant, address _longParticipant, address _shortRecipient, address _longRecipient, uint256 _price, address _sourceAccount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee) {

        require(isApprovedForAll(_shortParticipant, msg.sender) == true, "ERC1155: need operator approval to burn short account shares");
        require(isApprovedForAll(_longParticipant, msg.sender) == true, "ERC1155: need operator approval to burn long account shares");

        _internalTransferFrom(_shortParticipant, _longParticipant, getTokenId(_market, _outcome), _amount, bytes(""), false);

        (uint256 _payout, uint256 _creatorFee, uint256 _reportingFee) = burnCompleteSets(_market, _longParticipant, _amount, _sourceAccount, _fingerprint);

        {
            uint256 _longPayout = _payout.mul(_price) / _market.getNumTicks();
            require(cash.transfer(_longRecipient, _longPayout));
            require(cash.transfer(_shortRecipient, _payout.sub(_longPayout)));
        }

        assertBalances(_market);
        return (_creatorFee, _reportingFee);
    }

    function burnCompleteSets(IMarket _market, address _account, uint256 _amount, address _sourceAccount, bytes32 _fingerprint) private returns (uint256 _payout, uint256 _creatorFee, uint256 _reportingFee) {

        uint256 _numOutcomes = markets[address(_market)].numOutcomes;
        uint256 _numTicks = markets[address(_market)].numTicks;

        require(_numOutcomes != 0, "Invalid Market provided");

        {
            uint256[] memory _tokenIds = new uint256[](_numOutcomes);
            uint256[] memory _values = new uint256[](_numOutcomes);

            for (uint256 i = 0; i < _numOutcomes; i++) {
                _tokenIds[i] = TokenId.getTokenId(_market, i);
                _values[i] = _amount;
            }

            _burnBatch(_account, _tokenIds, _values, bytes(""), false);
        }

        _payout = _amount.mul(_numTicks);
        IUniverse _universe = _market.getUniverse();

        if (!_market.isFinalized()) {
            _universe.decrementOpenInterest(_payout);
        }

        _creatorFee = _market.deriveMarketCreatorFeeAmount(_payout);
        uint256 _reportingFeeDivisor = _universe.getOrCacheReportingFeeDivisor();
        _reportingFee = _payout.div(_reportingFeeDivisor);
        _payout = _payout.sub(_creatorFee).sub(_reportingFee);

        if (_creatorFee != 0) {
            _market.recordMarketCreatorFees(_creatorFee, _sourceAccount, _fingerprint);
        }

        _universe.withdraw(address(this), _payout.add(_reportingFee), address(_market));

        if (_reportingFee != 0) {
            require(cash.transfer(address(_universe.getOrCreateNextDisputeWindow(false)), _reportingFee));
        }

        augur.logMarketOIChanged(_universe, _market);
    }

    function claimTradingProceeds(IMarket _market, address _shareHolder, bytes32 _fingerprint) external nonReentrant returns (uint256[] memory _outcomeFees) {

        return claimTradingProceedsInternal(_market, _shareHolder, _fingerprint);
    }

    function claimTradingProceedsInternal(IMarket _market, address _shareHolder, bytes32 _fingerprint) internal returns (uint256[] memory _outcomeFees) {

        require(augur.isKnownMarket(_market));
        if (!_market.isFinalized()) {
            _market.finalize();
        }
        _outcomeFees = new uint256[](8);
        for (uint256 _outcome = 0; _outcome < _market.getNumberOfOutcomes(); ++_outcome) {
            uint256 _numberOfShares = balanceOfMarketOutcome(_market, _outcome, _shareHolder);

            if (_numberOfShares > 0) {
                uint256 _proceeds;
                uint256 _shareHolderShare;
                uint256 _creatorShare;
                uint256 _reporterShare;
                uint256 _tokenId = TokenId.getTokenId(_market, _outcome);
                (_proceeds, _shareHolderShare, _creatorShare, _reporterShare) = divideUpWinnings(_market, _outcome, _numberOfShares);

                _burn(_shareHolder, _tokenId, _numberOfShares, bytes(""), false);
                logTradingProceedsClaimed(_market, _outcome, _shareHolder, _numberOfShares, _shareHolderShare, _creatorShare.add(_reporterShare));

                if (_proceeds > 0) {
                    _market.getUniverse().withdraw(address(this), _shareHolderShare.add(_reporterShare), address(_market));
                    distributeProceeds(_market, _shareHolder, _shareHolderShare, _creatorShare, _reporterShare, _fingerprint);
                }
                _outcomeFees[_outcome] = _creatorShare.add(_reporterShare);
            }
        }

        assertBalances(_market);
        return _outcomeFees;
    }

    function distributeProceeds(IMarket _market, address _shareHolder, uint256 _shareHolderShare, uint256 _creatorShare, uint256 _reporterShare, bytes32 _fingerprint) private {

        if (_shareHolderShare > 0) {
            require(cash.transfer(_shareHolder, _shareHolderShare));
        }
        if (_creatorShare > 0) {
            _market.recordMarketCreatorFees(_creatorShare, _shareHolder, _fingerprint);
        }
        if (_reporterShare > 0) {
            require(cash.transfer(address(_market.getUniverse().getOrCreateNextDisputeWindow(false)), _reporterShare));
        }
    }

    function logTradingProceedsClaimed(IMarket _market, uint256 _outcome, address _sender, uint256 _numShares, uint256 _numPayoutTokens, uint256 _fees) private {

        augur.logTradingProceedsClaimed(_market.getUniverse(), _sender, address(_market), _outcome, _numShares, _numPayoutTokens, _fees);
    }

    function divideUpWinnings(IMarket _market, uint256 _outcome, uint256 _numberOfShares) public returns (uint256 _proceeds, uint256 _shareHolderShare, uint256 _creatorShare, uint256 _reporterShare) {

        _proceeds = calculateProceeds(_market, _outcome, _numberOfShares);
        _creatorShare = calculateCreatorFee(_market, _proceeds);
        _reporterShare = calculateReportingFee(_market, _proceeds);
        _shareHolderShare = _proceeds.sub(_creatorShare).sub(_reporterShare);
        return (_proceeds, _shareHolderShare, _creatorShare, _reporterShare);
    }

    function calculateProceeds(IMarket _market, uint256 _outcome, uint256 _numberOfShares) public view returns (uint256) {

        uint256 _payoutNumerator = _market.getWinningPayoutNumerator(_outcome);
        return _numberOfShares.mul(_payoutNumerator);
    }

    function calculateReportingFee(IMarket _market, uint256 _amount) public returns (uint256) {

        uint256 _reportingFeeDivisor = _market.getUniverse().getOrCacheReportingFeeDivisor();
        return _amount.div(_reportingFeeDivisor);
    }

    function calculateCreatorFee(IMarket _market, uint256 _amount) public view returns (uint256) {

        return _market.deriveMarketCreatorFeeAmount(_amount);
    }

    function getTypeName() public view returns(bytes32) {

        return "ShareToken";
    }

    function getMarket(uint256 _tokenId) external view returns(IMarket) {

        (address _market, uint256 _outcome) = TokenId.unpackTokenId(_tokenId);
        return IMarket(_market);
    }

    function getOutcome(uint256 _tokenId) external view returns(uint256) {

        (address _market, uint256 _outcome) = TokenId.unpackTokenId(_tokenId);
        return _outcome;
    }

    function totalSupplyForMarketOutcome(IMarket _market, uint256 _outcome) public view returns (uint256) {

        uint256 _tokenId = TokenId.getTokenId(_market, _outcome);
        return totalSupply(_tokenId);
    }

    function balanceOfMarketOutcome(IMarket _market, uint256 _outcome, address _account) public view returns (uint256) {

        uint256 _tokenId = TokenId.getTokenId(_market, _outcome);
        return balanceOf(_account, _tokenId);
    }

    function lowestBalanceOfMarketOutcomes(IMarket _market, uint256[] memory _outcomes, address _account) public view returns (uint256) {

        uint256 _lowest = SafeMathUint256.getUint256Max();
        for (uint256 _i = 0; _i < _outcomes.length; ++_i) {
            uint256 _tokenId = TokenId.getTokenId(_market, _outcomes[_i]);
            _lowest = balanceOf(_account, _tokenId).min(_lowest);
        }
        return _lowest;
    }

    function assertBalances(IMarket _market) public view {

        uint256 _expectedBalance = 0;
        uint256 _numTicks = _market.getNumTicks();
        uint256 _numOutcomes = _market.getNumberOfOutcomes();
        if (_market.isFinalized()) {
            for (uint8 i = 0; i < _numOutcomes; i++) {
                _expectedBalance = _expectedBalance.add(totalSupplyForMarketOutcome(_market, i).mul(_market.getWinningPayoutNumerator(i)));
            }
        } else {
            _expectedBalance = totalSupplyForMarketOutcome(_market, 0).mul(_numTicks);
        }

        assert(_market.getUniverse().marketBalance(address(_market)) >= _expectedBalance);
    }

    function getTokenId(IMarket _market, uint256 _outcome) public pure returns (uint256 _tokenId) {

        return TokenId.getTokenId(_market, _outcome);
    }

    function getTokenIds(IMarket _market, uint256[] memory _outcomes) public pure returns (uint256[] memory _tokenIds) {

        return TokenId.getTokenIds(_market, _outcomes);
    }

    function unpackTokenId(uint256 _tokenId) public pure returns (address _market, uint256 _outcome) {

        return TokenId.unpackTokenId(_tokenId);
    }

    function onTokenTransfer(uint256 _tokenId, address _from, address _to, uint256 _value) internal {

        (address _marketAddress, uint256 _outcome) = TokenId.unpackTokenId(_tokenId);
        augur.logShareTokensBalanceChanged(_from, IMarket(_marketAddress), _outcome, balanceOf(_from, _tokenId));
        augur.logShareTokensBalanceChanged(_to, IMarket(_marketAddress), _outcome, balanceOf(_to, _tokenId));
    }

    function onMint(uint256 _tokenId, address _target, uint256 _amount) internal {

        (address _marketAddress, uint256 _outcome) = TokenId.unpackTokenId(_tokenId);
        augur.logShareTokensBalanceChanged(_target, IMarket(_marketAddress), _outcome, balanceOf(_target, _tokenId));
    }

    function onBurn(uint256 _tokenId, address _target, uint256 _amount) internal {

        (address _marketAddress, uint256 _outcome) = TokenId.unpackTokenId(_tokenId);
        augur.logShareTokensBalanceChanged(_target, IMarket(_marketAddress), _outcome, balanceOf(_target, _tokenId));
    }
}